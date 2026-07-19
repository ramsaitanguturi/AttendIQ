import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'backup_exporter.dart';
import 'backup_importer.dart';
import 'backup_models.dart';

class BackupService {
  final Isar _isar;
  final BackupExporter _exporter;
  final BackupImporter _importer;

  BackupService(this._isar)
      : _exporter = BackupExporter(_isar),
        _importer = BackupImporter(_isar);

  /// Extensible encoding hook (AES encryption can be plugged in here in future)
  Future<String> encodeBackupPayload(BackupData data, {String? encryptionKey}) async {
    final rawJson = _exporter.exportToJsonString();
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

  /// Exports backup to a default file on local storage and returns file path
  Future<String> exportToFile({String? customFileName}) async {
    final jsonContent = await exportBackupString();
    final fileName = customFileName ??
        'attendiq_backup_${DateTime.now().millisecondsSinceEpoch}.attendiq';
    
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonContent);
    return file.path;
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
