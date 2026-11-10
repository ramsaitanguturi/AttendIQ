import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:share_plus/share_plus.dart';
import 'backup_exporter.dart';
import 'backup_importer.dart';
import 'backup_models.dart';
import 'backup_path_helper.dart';

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
  final Isar _isar;
  final BackupExporter _exporter;
  final BackupImporter _importer;

  BackupService(this._isar)
      : _exporter = BackupExporter(_isar),
        _importer = BackupImporter(_isar);

  /// Extensible encoding hook (AES encryption can be plugged in here in future)
  Future<String> encodeBackupPayload(BackupData data, {String? encryptionKey}) async {
    final rawJson = await _exporter.exportToJsonString();
    if (encryptionKey != null && encryptionKey.isNotEmpty) {
      // Future extension: return aesEncrypt(rawJson, encryptionKey);
    }
    return rawJson;
  }

  /// Extensible decoding hook (AES decryption can be plugged in here in future)
  Future<String> decodeBackupPayload(String rawContent, {String? encryptionKey}) async {
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
  Future<String> exportToFile({String? semesterName, String? customFileName}) async {
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
  Future<String> exportDataJsonFile({String? semesterName, String? customFileName}) async {
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
  Future<PickedBackupResult?> pickImportFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['attendiq', 'json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';
        String filePath = file.path ?? file.name;

        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          final fileOnDisk = File(file.path!);
          if (await fileOnDisk.exists()) {
            content = await fileOnDisk.readAsString();
          }
        }

        if (content.isNotEmpty) {
          return PickedBackupResult(
            filePath: filePath,
            fileName: file.name,
            content: content,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Validates a raw backup JSON string
  BackupData validateBackup(String rawJson) {
    return _importer.parseAndValidateJson(rawJson);
  }

  /// Imports data from a raw backup JSON string with strategy (replace or merge)
  Future<void> importFromBackupString(
    String rawJson, {
    ImportStrategy strategy = ImportStrategy.replace,
  }) async {
    final decoded = await decodeBackupPayload(rawJson);
    await _importer.importData(decoded, strategy: strategy);
  }

  /// Imports data directly from a file path
  Future<void> importFromFile(
    String filePath, {
    ImportStrategy strategy = ImportStrategy.replace,
  }) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Backup file not found at path: $filePath');
    }
    final rawJson = await file.readAsString();
    await importFromBackupString(rawJson, strategy: strategy);
  }
}
