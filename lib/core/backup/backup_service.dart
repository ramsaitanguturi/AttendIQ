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

typedef ShareFilesHandler = Future<void> Function(
  List<XFile> files, {
  String? text,
  String? subject,
});

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
  final Directory? _backupsDirOverride;
  final Directory? _privateExportBaseDirOverride;
  final Directory? _tempDirOverride;
  final bool? _isAndroidOverride;
  final ShareFilesHandler? _shareFilesOverride;

  BackupService(
    Isar isar, {
    @visibleForTesting Future<PlatformFile?> Function()? pickFileOverride,
    Directory? backupsDirOverride,
    @visibleForTesting Directory? privateExportBaseDirOverride,
    @visibleForTesting Directory? tempDirOverride,
    @visibleForTesting bool? isAndroidOverride,
    @visibleForTesting ShareFilesHandler? shareFilesOverride,
  })  : _exporter = BackupExporter(isar),
        _importer = BackupImporter(isar),
        _pickFileOverride = pickFileOverride,
        _backupsDirOverride = backupsDirOverride,
        _privateExportBaseDirOverride = privateExportBaseDirOverride,
        _tempDirOverride = tempDirOverride,
        _isAndroidOverride = isAndroidOverride,
        _shareFilesOverride = shareFilesOverride;

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

  /// Writes the authoritative `.attendiq` backup to app-private `backups/`,
  /// verifies the write, and on Android 10+ (API 29+) optionally mirrors a
  /// public `MediaStore` copy when [saveToAppPrivateOnly] is `false`.
  ///
  /// On Android 6-9 (API 23-28), this remains prompt-free by skipping SAF
  /// unless the user explicitly invokes [saveBackupCopyToPublicStorage].
  Future<ExportSaveResult> exportToFileResult({
    String? semesterName,
    String? customFileName,
    bool saveToAppPrivateOnly = false,
  }) async {
    final jsonContent = await exportBackupString();
    final rawFileName = customFileName ??
        await BackupPathHelper.generateFileName(
          type: 'Backup',
          extension: 'attendiq',
          semesterName: semesterName,
        );
    final fileName = BackupPathHelper.validateFileName(rawFileName);
    final bytes = utf8.encode(jsonContent);

    // 1. Always write and verify the app-private backup first.
    final privateResult = await BackupPathHelper.saveAppPrivateBackup(
      fileName: fileName,
      bytes: bytes,
      backupsDirOverride: _backupsDirOverride,
    );
    final localPath = privateResult.localFilePath;
    if (localPath == null || !await File(localPath).exists()) {
      throw const FileSystemException(
        'App-private backup verification failed after write.',
      );
    }

    final isAndroid = _isAndroidOverride ?? (Platform.isAndroid && !kIsWeb);
    if (saveToAppPrivateOnly || !isAndroid) {
      return privateResult;
    }

    // 2. Attempt optional silent MediaStore public copy (API 29+); never
    // invalidate or delete the app-private backup if public mirroring fails.
    try {
      final publicResult = await BackupPathHelper.savePublicExportFile(
        fileName: fileName,
        bytes: bytes,
        subFolder: 'Backups',
        mimeType: 'application/octet-stream',
        allowDocumentPicker: false,
        stageShareCopy: false,
        isAndroidOverride: _isAndroidOverride,
        privateExportBaseDirOverride: _privateExportBaseDirOverride,
        tempDirectoryOverride: _tempDirOverride,
      );

      if (publicResult.hasContentUri) {
        return privateResult.copyWith(
          contentUri: publicResult.contentUri,
          displayPath: publicResult.displayPath,
          fileName: publicResult.fileName,
        );
      }
    } catch (_) {
      // Keep the verified app-private backup intact.
    }

    return privateResult;
  }

  /// Exports backup (.attendiq) to app-private `backups/` and returns its
  /// canonical local filesystem path for existing callers.
  Future<String> exportToFile({
    String? semesterName,
    String? customFileName,
    bool saveToAppPrivateOnly = false,
  }) async {
    final result = await exportToFileResult(
      semesterName: semesterName,
      customFileName: customFileName,
      saveToAppPrivateOnly: saveToAppPrivateOnly,
    );
    return result.localFilePath!;
  }

  /// Exports JSON data export file (.json) via `MediaStore` (API 29+) or SAF
  /// `ACTION_CREATE_DOCUMENT` (API 23-28), returning the rich path/URI result.
  Future<ExportSaveResult> exportDataJsonResult({
    String? semesterName,
    String? customFileName,
  }) async {
    final jsonContent = await exportBackupString();
    final rawFileName = customFileName ??
        await BackupPathHelper.generateFileName(
          type: 'Data',
          extension: 'json',
          semesterName: semesterName,
        );
    final fileName = BackupPathHelper.validateFileName(rawFileName);

    return BackupPathHelper.savePublicExportFile(
      fileName: fileName,
      bytes: utf8.encode(jsonContent),
      subFolder: 'Exports',
      mimeType: 'application/json',
      allowDocumentPicker: true,
      stageShareCopy: true,
      isAndroidOverride: _isAndroidOverride,
      privateExportBaseDirOverride: _privateExportBaseDirOverride,
      tempDirectoryOverride: _tempDirOverride,
    );
  }

  /// Exports JSON data export file (.json) and returns its URI or local path.
  Future<String> exportDataJsonFile({
    String? semesterName,
    String? customFileName,
  }) async {
    final result = await exportDataJsonResult(
      semesterName: semesterName,
      customFileName: customFileName,
    );
    return result.contentUri ?? result.localFilePath ?? '';
  }

  /// Explicitly saves a public copy of an existing app-private backup using
  /// `MediaStore` (API 29+) or SAF `ACTION_CREATE_DOCUMENT` (API 23-28).
  Future<ExportSaveResult> saveBackupCopyToPublicStorage(
    String backupFilePath,
  ) async {
    final backupsDir = await BackupPathHelper.getAppBackupsDirectory(
      backupsDirOverride: _backupsDirOverride,
    );
    final validatedPath =
        await BackupPathHelper.resolveValidatedPathInDirectory(
      candidatePath: backupFilePath,
      rootDirectory: backupsDir,
      mustExist: true,
    );
    final file = File(validatedPath);
    final bytes = await file.readAsBytes();
    final fileName = BackupPathHelper.validateFileName(
      validatedPath.split(Platform.pathSeparator).last,
    );

    final publicResult = await BackupPathHelper.savePublicExportFile(
      fileName: fileName,
      bytes: bytes,
      subFolder: 'Backups',
      mimeType: 'application/octet-stream',
      allowDocumentPicker: true,
      stageShareCopy: false,
      isAndroidOverride: _isAndroidOverride,
      privateExportBaseDirOverride: _privateExportBaseDirOverride,
      tempDirectoryOverride: _tempDirOverride,
    );

    if (publicResult.wasCancelled) {
      return publicResult;
    }

    return ExportSaveResult(
      localFilePath: validatedPath,
      contentUri: publicResult.contentUri,
      shareableFilePath: validatedPath,
      displayPath: publicResult.displayPath,
      fileName: publicResult.fileName,
      subFolder: 'Backups',
    );
  }

  /// Lists all backup files from the app-private `backups/` directory.
  Future<List<BackupFileItem>> listBackups() async {
    return BackupPathHelper.listBackupFiles(
      backupsDirOverride: _backupsDirOverride,
    );
  }

  /// Deletes a backup file strictly contained within app-private `backups/`.
  Future<bool> deleteBackupFile(String filePath) async {
    try {
      final backupsDir = await BackupPathHelper.getAppBackupsDirectory(
        backupsDirOverride: _backupsDirOverride,
      );
      final validatedPath =
          await BackupPathHelper.resolveValidatedPathInDirectory(
        candidatePath: filePath,
        rootDirectory: backupsDir,
        mustExist: true,
      );
      await File(validatedPath).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Shares an app-private backup file strictly contained within `backups/`
  /// using `share_plus` (which uses its own `ShareFileProvider`).
  Future<void> shareBackupFile(String filePath, {String? text}) async {
    final backupsDir = await BackupPathHelper.getAppBackupsDirectory(
      backupsDirOverride: _backupsDirOverride,
    );
    final validatedPath =
        await BackupPathHelper.resolveValidatedPathInDirectory(
      candidatePath: filePath,
      rootDirectory: backupsDir,
      mustExist: true,
    );

    final isBeta = await BackupPathHelper.isBetaApp();
    final appName = isBeta ? 'ACEDRA Beta' : 'ACEDRA';
    final shareHandler = _shareFilesOverride;
    if (shareHandler != null) {
      await shareHandler(
        [XFile(validatedPath)],
        text: text ?? '$appName File Export',
        subject: '$appName Export',
      );
      return;
    }

    await Share.shareXFiles(
      [XFile(validatedPath)],
      text: text ?? '$appName File Export',
      subject: '$appName Export',
    );
  }

  static const Set<String> _supportedImportExtensions = <String>{
    'attendiq',
    'json',
  };

  /// Opens target file picker dialog allowing user to select `.attendiq` or `.json` files
  /// from Downloads, Documents, File Manager, or Google Drive via SAF.
  ///
  /// Uses [FileType.any] on Android because `file_picker` 8.3.2 cannot map
  /// custom `.attendiq` (or `.json` on API 28/29) extensions to MIME types in
  /// `FilePickerUtils`, then validates extension, size, UTF-8 encoding, and
  /// JSON payload structure in Dart after selection.
  ///
  /// Returns `null` only when the user cancels the picker. Unsupported
  /// extensions, empty files, oversized files (> 20 MB), invalid UTF-8 bytes,
  /// malformed JSON payloads, and IO failures throw explicit exceptions for UI
  /// reporting.
  Future<PickedBackupResult?> pickImportFile() async {
    final PlatformFile? file;
    final pickOverride = _pickFileOverride;
    if (pickOverride != null) {
      file = await pickOverride();
    } else {
      final isAndroid = _isAndroidOverride ?? (Platform.isAndroid && !kIsWeb);
      final result = await FilePicker.platform.pickFiles(
        type: isAndroid ? FileType.any : FileType.custom,
        allowedExtensions:
            isAndroid ? null : const <String>['attendiq', 'json'],
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

    final filePath = kIsWeb ? null : file.path;
    _validateSupportedImportExtension(file.name, filePath);

    if (file.size > maxBackupPayloadBytes) {
      throw const FormatException(
        'Backup file exceeds maximum supported size of 20 MB.',
      );
    }

    final trimmedPath = filePath?.trim();
    final lowerPath = trimmedPath?.toLowerCase();
    final hasReadableFilesystemPath = trimmedPath != null &&
        trimmedPath.isNotEmpty &&
        !lowerPath!.startsWith('content://') &&
        !lowerPath.startsWith('file://');

    final String content;
    if (hasReadableFilesystemPath) {
      content = await _readRawFileContent(trimmedPath);
    } else if (file.bytes != null) {
      content = _decodeBackupBytes(file.bytes!);
    } else {
      throw FileSystemException(
        'Selected backup file could not be read.',
        file.name,
      );
    }

    BackupValidator.decodeRawJson(content);

    return PickedBackupResult(
      filePath: hasReadableFilesystemPath ? trimmedPath : file.name,
      fileName: file.name,
      content: content,
    );
  }

  static void _validateSupportedImportExtension(
    String fileName,
    String? filePath,
  ) {
    final trimmedName = fileName.trim();
    final nameExt = _extractExtension(trimmedName);
    if (nameExt != null) {
      if (_supportedImportExtensions.contains(nameExt)) {
        return;
      }
      throw FormatException(
        'Unsupported backup file "$trimmedName". Please select a .attendiq or .json file.',
      );
    }

    if (filePath != null && filePath.trim().isNotEmpty) {
      final pathExt = _extractExtension(filePath.trim());
      if (pathExt != null && _supportedImportExtensions.contains(pathExt)) {
        return;
      }
    }

    final displayName =
        trimmedName.isNotEmpty ? trimmedName : (filePath?.trim() ?? 'unknown');
    throw FormatException(
      'Unsupported backup file "$displayName". Please select a .attendiq or .json file.',
    );
  }

  static String? _extractExtension(String rawNameOrPath) {
    final baseName = rawNameOrPath.split(RegExp(r'[/\\]')).last.trim();
    if (baseName.isEmpty) {
      return null;
    }
    final dotIndex = baseName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == baseName.length - 1) {
      return null;
    }
    return baseName.substring(dotIndex + 1).toLowerCase();
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

  /// Reads (with canonical containment inside `backups/`, size, and UTF-8
  /// checks) and validates a managed backup file before restore confirmations.
  Future<BackupData> validateManagedBackupFile(
    String filePath, {
    ImportStrategy? strategy = ImportStrategy.replace,
    String? encryptionKey,
  }) async {
    final backupsDir = await BackupPathHelper.getAppBackupsDirectory(
      backupsDirOverride: _backupsDirOverride,
    );
    final validatedPath =
        await BackupPathHelper.resolveValidatedPathInDirectory(
      candidatePath: filePath,
      rootDirectory: backupsDir,
      mustExist: true,
    );
    final rawJson = await _readRawFileContent(validatedPath);
    return validateBackupPayload(
      rawJson,
      strategy: strategy,
      encryptionKey: encryptionKey,
    );
  }

  /// Imports data from a managed backup file after verifying canonical
  /// containment inside `backups/` and pre-read validation.
  Future<void> importManagedBackupFile(
    String filePath, {
    ImportStrategy strategy = ImportStrategy.replace,
    String? encryptionKey,
  }) async {
    final backupsDir = await BackupPathHelper.getAppBackupsDirectory(
      backupsDirOverride: _backupsDirOverride,
    );
    final validatedPath =
        await BackupPathHelper.resolveValidatedPathInDirectory(
      candidatePath: filePath,
      rootDirectory: backupsDir,
      mustExist: true,
    );
    final rawJson = await _readRawFileContent(validatedPath);
    await importFromBackupString(
      rawJson,
      strategy: strategy,
      encryptionKey: encryptionKey,
    );
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
    final trimmed = filePath.trim();
    final lower = trimmed.toLowerCase();
    if (trimmed.isEmpty ||
        trimmed.contains('\u0000') ||
        lower.startsWith('content://') ||
        lower.startsWith('file://')) {
      throw FileSystemException(
        'Invalid filesystem backup path.',
        filePath,
      );
    }

    final entityType = FileSystemEntity.typeSync(
      trimmed,
      followLinks: false,
    );
    if (entityType == FileSystemEntityType.link) {
      throw FileSystemException(
        'Symbolic links cannot be imported as backup files.',
        filePath,
      );
    }
    if (entityType != FileSystemEntityType.file) {
      throw FileSystemException(
        'Backup file not found at path: $filePath',
        filePath,
      );
    }

    final canonicalPath = File(trimmed).resolveSymbolicLinksSync();
    final file = File(canonicalPath);
    final sizeBytes = file.lengthSync();
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
