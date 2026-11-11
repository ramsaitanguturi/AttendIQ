import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:share_plus/share_plus.dart';

import 'backup_exporter.dart';
import 'backup_importer.dart';
import 'backup_models.dart';
import 'backup_path_helper.dart';
import 'backup_validator.dart';

class PickedBackupResult {
  final String filePath;
  final String fileName;
  final String content;

  PickedBackupResult({
    required this.filePath,
    required this.fileName,
    required this.content,
  });
}

class BackupService {
  final BackupExporter _exporter;
  final BackupImporter _importer;
  final Future<PlatformFile?> Function()? _pickFileOverride;

  BackupService(
    Isar isar, {
    @visibleForTesting Future<PlatformFile?> Function()? pickFileOverride,
  })  : _exporter = BackupExporter(isar),
        _importer = BackupImporter(isar),
        _pickFileOverride = pickFileOverride;

  /// Extensible encoding hook (AES encryption can be plugged in here in future)
  Future<String> encodeBackupPayload(
    BackupData data, {
    String? encryptionKey,
  }) async {
    final rawJson = await _exporter.exportToJsonString();
    if (encryptionKey != null && encryptionKey.isNotEmpty) {
      // Future extension: return aesEncrypt(rawJson, encryptionKey);
    }
    return rawJson;
  }

  /// Extensible decoding hook (AES decryption can be plugged in here in future)
  Future<String> decodeBackupPayload(
    String rawContent, {
    String? encryptionKey,
  }) async {
    if (encryptionKey != null && encryptionKey.isNotEmpty) {
      // Future extension: return aesDecrypt(rawContent, encryptionKey);
    }
    return rawContent;
  }

  /// Generates backup JSON content string
  Future<String> exportBackupString({String appVersion = '1.1.0'}) async {
    return _exporter.exportToJsonString(appVersion: appVersion);
  }

  /// Exports backup (.attendiq) to user-accessible `Documents/AttendIQ (Beta)/Backups/`
  Future<String> exportToFile({
    String? semesterName,
    String? customFileName,
  }) async {
    final jsonContent = await exportBackupString();
    final fileName = customFileName ??
        await BackupPathHelper.generateFileName(
          type: 'Backup',
          extension: 'attendiq',
          semesterName: semesterName,
        );

    final path = await BackupPathHelper.saveExportFile(
      fileName: fileName,
      bytes: utf8.encode(jsonContent),
      subFolder: 'Backups',
      mimeType: 'application/octet-stream',
    );

    return path;
  }

  /// Exports JSON data export file (.json) to `Documents/AttendIQ (Beta)/Exports/`
  Future<String> exportDataJsonFile({
    String? semesterName,
    String? customFileName,
  }) async {
    final jsonContent = await exportBackupString();
    final fileName = customFileName ??
        await BackupPathHelper.generateFileName(
          type: 'Data',
          extension: 'json',
          semesterName: semesterName,
        );

    final path = await BackupPathHelper.saveExportFile(
      fileName: fileName,
      bytes: utf8.encode(jsonContent),
      subFolder: 'Exports',
      mimeType: 'application/json',
    );

    return path;
  }

  /// Lists all backup files from the public `Documents/AttendIQ (Beta)/Backups` directory
  Future<List<BackupFileItem>> listBackups() async {
    return BackupPathHelper.listBackupFiles();
  }

  /// Deletes a backup file by path
  Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Shares a backup file using system share dialog (WhatsApp, Drive, Telegram, Email, etc.)
  Future<void> shareBackupFile(String filePath, {String? text}) async {
    final file = File(filePath);
    if (await file.exists()) {
      final isBeta = await BackupPathHelper.isBetaApp();
      final appName = isBeta ? 'AttendIQ Beta' : 'AttendIQ';
      await Share.shareXFiles(
        [XFile(filePath)],
        text: text ?? '$appName File Export',
        subject: '$appName Export',
      );
    } else {
      throw FileSystemException('File not found at path: $filePath');
    }
  }

  /// Opens target file picker dialog allowing user to select `.attendiq` or `.json` files
  /// from Downloads, Documents, File Manager, or Google Drive.
  ///
  /// Returns `null` only when the user cancels the picker. Empty files,
  /// oversized files (> 20 MB), invalid UTF-8 bytes, and IO failures throw
  /// explicit exceptions for UI reporting.
  Future<PickedBackupResult?> pickImportFile() async {
    final PlatformFile? file;
    final pickOverride = _pickFileOverride;
    if (pickOverride != null) {
      file = await pickOverride();
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['attendiq', 'json'],
        withData: kIsWeb,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }
      file = result.files.first;
    }

    if (file == null) {
      return null;
    }

    if (file.size > maxBackupPayloadBytes) {
      throw const FormatException(
        'Backup file exceeds maximum supported size of 20 MB.',
      );
    }

    final filePath = file.path;
    final String content;
    if (filePath != null && filePath.trim().isNotEmpty) {
      content = await _readRawFileContent(filePath);
    } else if (file.bytes != null) {
      content = _decodeBackupBytes(file.bytes!);
    } else {
      throw FileSystemException(
        'Selected backup file could not be read.',
        file.name,
      );
    }

    return PickedBackupResult(
      filePath: filePath ?? file.name,
      fileName: file.name,
      content: content,
    );
  }

  /// Validates a raw backup JSON string synchronously.
  BackupData validateBackup(
    String rawJson, {
    ImportStrategy? strategy = ImportStrategy.replace,
  }) {
    return _importer.parseAndValidateJson(rawJson, strategy: strategy);
  }

  /// Decodes and validates a raw backup payload through the unified pipeline.
  Future<BackupData> validateBackupPayload(
    String rawJson, {
    ImportStrategy? strategy = ImportStrategy.replace,
    String? encryptionKey,
  }) async {
    BackupValidator.validatePayloadSize(rawJson);
    final decoded = await decodeBackupPayload(
      rawJson,
      encryptionKey: encryptionKey,
    );
    return _importer.parseAndValidateJson(decoded, strategy: strategy);
  }

  /// Reads (with size/UTF-8 checks) and validates a backup file on disk before
  /// exposing destructive import confirmations.
  Future<BackupData> validateBackupFile(
    String filePath, {
    ImportStrategy? strategy = ImportStrategy.replace,
    String? encryptionKey,
  }) async {
    final rawJson = await _readRawFileContent(filePath);
    return validateBackupPayload(
      rawJson,
      strategy: strategy,
      encryptionKey: encryptionKey,
    );
  }

  /// Imports data from a raw backup JSON string with strategy (replace or merge)
  Future<void> importFromBackupString(
    String rawJson, {
    ImportStrategy strategy = ImportStrategy.replace,
    String? encryptionKey,
  }) async {
    BackupValidator.validatePayloadSize(rawJson);
    final decoded = await decodeBackupPayload(
      rawJson,
      encryptionKey: encryptionKey,
    );
    await _importer.importData(decoded, strategy: strategy);
  }

  /// Imports data directly from a file path after pre-read size and UTF-8 checks.
  Future<void> importFromFile(
    String filePath, {
    ImportStrategy strategy = ImportStrategy.replace,
    String? encryptionKey,
  }) async {
    final rawJson = await _readRawFileContent(filePath);
    await importFromBackupString(
      rawJson,
      strategy: strategy,
      encryptionKey: encryptionKey,
    );
  }

  Future<String> _readRawFileContent(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException(
        'Backup file not found at path: $filePath',
        filePath,
      );
    }
    final sizeBytes = await file.length();
    if (sizeBytes == 0) {
      throw const FormatException('Backup file is empty.');
    }
    if (sizeBytes > maxBackupPayloadBytes) {
      throw const FormatException(
        'Backup file exceeds maximum supported size of 20 MB.',
      );
    }
    final bytes = await file.readAsBytes();
    return _decodeBackupBytes(bytes);
  }

  String _decodeBackupBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('Backup file is empty.');
    }
    if (bytes.length > maxBackupPayloadBytes) {
      throw const FormatException(
        'Backup file exceeds maximum supported size of 20 MB.',
      );
    }
    try {
      return utf8.decode(bytes);
    } on FormatException catch (e) {
      throw FormatException(
        'Backup file is not valid UTF-8 text: ${e.message}',
      );
    }
  }
}
