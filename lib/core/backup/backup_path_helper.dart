import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  static const MethodChannel _storageChannel = MethodChannel('com.ramsa.attendiq/storage');

  static bool? _cachedIsBeta;

  /// Determines if the running app build is AttendIQ Beta.
  static Future<bool> isBetaApp() async {
    if (_cachedIsBeta != null) return _cachedIsBeta!;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _cachedIsBeta = packageInfo.packageName.endsWith('.beta') ||
          packageInfo.appName.toLowerCase().contains('beta');
    } catch (_) {
      _cachedIsBeta = false;
    }
    return _cachedIsBeta!;
  }

  /// Returns the base folder name for exports (`AttendIQ Beta` or `AttendIQ`).
  static Future<String> getExportBaseFolderName() async {
    final isBeta = await isBetaApp();
    return isBeta ? 'AttendIQ Beta' : 'AttendIQ';
  }

  /// Returns filename prefix (`AttendIQ_Beta` or `AttendIQ`).
  static Future<String> getAppNamePrefix() async {
    final isBeta = await isBetaApp();
    return isBeta ? 'AttendIQ_Beta' : 'AttendIQ';
  }

  /// Formats semester string cleanly for filenames (e.g. "Semester 5" -> "Sem5").
  static String formatSemesterForFileName(String? semesterName) {
    if (semesterName == null || semesterName.trim().isEmpty) {
      return 'Sem1';
    }
    final trimmed = semesterName.trim();
    // Transform "Semester 5" -> "Sem5", "Semester_5" -> "Sem5", "Sem 5" -> "Sem5"
    final semMatch = RegExp(r'^(?:Semester|Sem)[\s_]*(\d+)$', caseSensitive: false).firstMatch(trimmed);
    if (semMatch != null) {
      return 'Sem${semMatch.group(1)}';
    }
    // Clean spaces and special characters
    final sanitized = trimmed.replaceAll(RegExp(r'[^\w\-]'), '_');
    return sanitized.isEmpty ? 'Sem1' : sanitized;
  }

  /// Generates a standardized export filename following the requirement format:
  /// `{AppName}_{Type}_{Semester}_{YYYY-MM-DD}.{ext}`
  static Future<String> generateFileName({
    required String type,
    required String extension,
    String? semesterName,
    DateTime? date,
  }) async {
    final appPrefix = await getAppNamePrefix();
    final semFormatted = formatSemesterForFileName(semesterName);
    final now = date ?? DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final cleanExt = extension.startsWith('.') ? extension.substring(1) : extension;

    return '${appPrefix}_${type}_${semFormatted}_$dateStr.$cleanExt';
  }

  /// Resolves local Directory object for `Documents/AttendIQ (Beta)/[subFolder]`.
  static Future<Directory> getExportDirectory({String subFolder = ''}) async {
    final baseFolderName = await getExportBaseFolderName();
    Directory targetDir;

    if (Platform.isAndroid) {
      const androidDocumentsPath = '/storage/emulated/0/Documents';
      final androidDocsDir = Directory(androidDocumentsPath);
      final folderPath = subFolder.isNotEmpty
          ? '$androidDocumentsPath/$baseFolderName/$subFolder'
          : '$androidDocumentsPath/$baseFolderName';
      if (await androidDocsDir.exists()) {
        targetDir = Directory(folderPath);
      } else {
        final appDocs = await getApplicationDocumentsDirectory();
        targetDir = subFolder.isNotEmpty
            ? Directory('${appDocs.path}/$baseFolderName/$subFolder')
            : Directory('${appDocs.path}/$baseFolderName');
      }
    } else {
      try {
        final appDocs = await getApplicationDocumentsDirectory();
        targetDir = subFolder.isNotEmpty
            ? Directory('${appDocs.path}/$baseFolderName/$subFolder')
            : Directory('${appDocs.path}/$baseFolderName');
      } catch (_) {
        targetDir = subFolder.isNotEmpty
            ? Directory('./$baseFolderName/$subFolder')
            : Directory('./$baseFolderName');
      }
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  /// Returns user-friendly folder path string for the UI.
  static Future<String> getDisplayFolderPath({String subFolder = ''}) async {
    final baseFolder = await getExportBaseFolderName();
    final pathSuffix = subFolder.isNotEmpty ? '$baseFolder/$subFolder' : baseFolder;
    if (Platform.isAndroid) {
      return 'Internal Storage/Documents/$pathSuffix';
    }
    return 'Documents/$pathSuffix';
  }

  /// Saves binary/string content to user-accessible public storage in `Documents/AttendIQ (Beta)/[subFolder]`.
  static Future<String> saveExportFile({
    required String fileName,
    required List<int> bytes,
    required String subFolder,
    required String mimeType,
  }) async {
    final isBeta = await isBetaApp();

    if (Platform.isAndroid && !kIsWeb) {
      try {
        final String? path = await _storageChannel.invokeMethod<String>('saveToPublicStorage', {
          'fileName': fileName,
          'bytes': Uint8List.fromList(bytes),
          'subFolder': subFolder,
          'mimeType': mimeType,
          'isBeta': isBeta,
        });
        if (path != null && path.isNotEmpty) {
          return path;
        }
      } catch (_) {
        // Fallback to direct dart file write below if channel method is unavailable
      }
    }

    final targetDir = await getExportDirectory(subFolder: subFolder);
    final file = File('${targetDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Opens the target export folder in system File Manager.
  static Future<bool> openExportFolder({String subFolder = ''}) async {
    final targetDir = await getExportDirectory(subFolder: subFolder);
    if (Platform.isAndroid && !kIsWeb) {
      try {
        final bool? success = await _storageChannel.invokeMethod<bool>('openFolder', {
          'folderPath': targetDir.path,
        });
        return success ?? false;
      } catch (_) {}
    }
    return false;
  }

  /// Opens an exported file (PDF, CSV, JSON, etc.) in an external app viewer.
  static Future<bool> openExportFile(String filePath, String mimeType) async {
    if (Platform.isAndroid && !kIsWeb) {
      try {
        final bool? success = await _storageChannel.invokeMethod<bool>('openFile', {
          'filePath': filePath,
          'mimeType': mimeType,
        });
        return success ?? false;
      } catch (_) {}
    }
    return false;
  }

  /// Lists all `.attendiq` backup files in the `Backups` subfolder (and legacy locations), sorted newest first.
  static Future<List<BackupFileItem>> listBackupFiles() async {
    try {
      final List<BackupFileItem> items = [];
      final Set<String> seenPaths = {};

      // 1. Backups subfolder (Primary)
      final backupsDir = await getExportDirectory(subFolder: 'Backups');
      if (await backupsDir.exists()) {
        final entities = await backupsDir.list().toList();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.attendiq')) {
            final stat = await entity.stat();
            final fileName = entity.path.split(Platform.pathSeparator).last;
            seenPaths.add(entity.path);
            items.add(BackupFileItem(
              fileName: fileName,
              filePath: entity.path,
              modifiedDate: stat.modified,
              sizeBytes: stat.size,
            ));
          }
        }
      }

      // 2. Legacy base directory check for existing files
      final baseDir = await getExportDirectory(subFolder: '');
      if (await baseDir.exists()) {
        final entities = await baseDir.list().toList();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.attendiq') && !seenPaths.contains(entity.path)) {
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
      }

      items.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
      return items;
    } catch (e) {
      return [];
    }
  }
}
