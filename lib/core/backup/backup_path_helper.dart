import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BackupFileItem {
  final String fileName;
  final String filePath;
  final DateTime modifiedDate;
  final int sizeBytes;

  BackupFileItem({
    required this.fileName,
    required this.filePath,
    required this.modifiedDate,
    required this.sizeBytes,
  });

  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      final kb = sizeBytes / 1024.0;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = sizeBytes / (1024.0 * 1024.0);
      return '${mb.toStringAsFixed(1)} MB';
    }
  }
}

class BackupPathHelper {
  static const String backupFolderName = 'AttendIQ Backups';

  /// Resolves the public export directory for AttendIQ backups.
  /// On Android, saves to `/storage/emulated/0/Documents/AttendIQ Backups`.
  /// On other platforms or fallbacks, saves to `Documents/AttendIQ Backups`.
  static Future<Directory> getBackupDirectory() async {
    Directory targetDir;

    if (Platform.isAndroid) {
      const androidDocumentsPath = '/storage/emulated/0/Documents';
      final androidDocsDir = Directory(androidDocumentsPath);
      if (await androidDocsDir.exists()) {
        targetDir = Directory('$androidDocumentsPath/$backupFolderName');
      } else {
        final appDocs = await getApplicationDocumentsDirectory();
        targetDir = Directory('${appDocs.path}/$backupFolderName');
      }
    } else {
      try {
        final appDocs = await getApplicationDocumentsDirectory();
        targetDir = Directory('${appDocs.path}/$backupFolderName');
      } catch (_) {
        targetDir = Directory('./$backupFolderName');
      }
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  /// Returns user-friendly folder path string for the UI.
  static String getDisplayFolderPath() {
    if (Platform.isAndroid) {
      return 'Internal Storage/Documents/$backupFolderName';
    }
    return 'Documents/$backupFolderName';
  }

  /// Lists all `.attendiq` backup files in the backup directory, sorted newest first.
  static Future<List<BackupFileItem>> listBackupFiles() async {
    try {
      final dir = await getBackupDirectory();
      if (!await dir.exists()) return [];

      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<BackupFileItem> items = [];

      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.attendiq')) {
          final stat = await entity.stat();
          final fileName = entity.path.split(Platform.pathSeparator).last;
          items.add(BackupFileItem(
            fileName: fileName,
            filePath: entity.path,
            modifiedDate: stat.modified,
            sizeBytes: stat.size,
          ));
        }
      }

      items.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
      return items;
    } catch (e) {
      return [];
    }
  }
}
