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

/// Result contract for backup and public export operations.
///
/// [localFilePath] and [contentUri] are independent nullable fields so a single
/// operation can represent both an app-private backup file and its optional
/// public MediaStore/SAF copy without fabricating filesystem paths for URIs.
class ExportSaveResult {
  final String? localFilePath;
  final String? contentUri;
  final String? shareableFilePath;
  final String displayPath;
  final String fileName;
  final String subFolder;
  final bool wasCancelled;

  const ExportSaveResult({
    this.localFilePath,
    this.contentUri,
    this.shareableFilePath,
    required this.displayPath,
    required this.fileName,
    required this.subFolder,
    this.wasCancelled = false,
  });

  bool get hasLocalFile => localFilePath != null && localFilePath!.isNotEmpty;

  bool get hasContentUri => contentUri != null && contentUri!.isNotEmpty;

  /// Verified local filesystem path eligible for sharing via `share_plus`.
  String? get effectiveSharePath {
    if (hasLocalFile) return localFilePath;
    if (shareableFilePath != null && shareableFilePath!.isNotEmpty) {
      return shareableFilePath;
    }
    return null;
  }

  ExportSaveResult copyWith({
    String? localFilePath,
    String? contentUri,
    String? shareableFilePath,
    String? displayPath,
    String? fileName,
    String? subFolder,
    bool? wasCancelled,
  }) {
    return ExportSaveResult(
      localFilePath: localFilePath ?? this.localFilePath,
      contentUri: contentUri ?? this.contentUri,
      shareableFilePath: shareableFilePath ?? this.shareableFilePath,
      displayPath: displayPath ?? this.displayPath,
      fileName: fileName ?? this.fileName,
      subFolder: subFolder ?? this.subFolder,
      wasCancelled: wasCancelled ?? this.wasCancelled,
    );
  }
}

class BackupPathHelper {
  static const MethodChannel _storageChannel =
      MethodChannel('com.ramsa.attendiq/storage');

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
    final semMatch = RegExp(
      r'^(?:Semester|Sem)[\s_]*(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
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
    final cleanExt =
        extension.startsWith('.') ? extension.substring(1) : extension;

    return validateFileName(
      '${appPrefix}_${type}_${semFormatted}_$dateStr.$cleanExt',
    );
  }

  /// Validates that [rawName] is a single safe filename without path separators,
  /// traversal segments, or control characters.
  static String validateFileName(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty ||
        trimmed == '.' ||
        trimmed == '..' ||
        trimmed.contains('/') ||
        trimmed.contains('\\') ||
        trimmed.contains('..') ||
        trimmed.contains('\u0000')) {
      throw FileSystemException('Invalid storage filename.', rawName);
    }
    return trimmed;
  }

  /// Sanitizes a relative subfolder label (e.g., `Reports`, `Exports`).
  static String sanitizeSubFolder(String rawSubFolder) {
    final segments = rawSubFolder
        .split(RegExp(r'[/\\]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s != '.' && s != '..')
        .toList(growable: false);
    return segments.join('/');
  }

  /// Returns the canonical app-private `backups/` directory used by Backup
  /// Manager and automatic backups.
  static Future<Directory> getAppBackupsDirectory({
    Directory? baseDirectoryOverride,
    Directory? backupsDirOverride,
  }) async {
    if (backupsDirOverride != null) {
      return _resolveCanonicalRootDirectorySync(backupsDirOverride);
    }

    final Directory baseDir;
    if (baseDirectoryOverride != null) {
      baseDir = baseDirectoryOverride;
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final canonicalParent = _resolveCanonicalRootDirectorySync(baseDir);
    final backupsDir =
        Directory('${canonicalParent.path}${Platform.pathSeparator}backups');
    return _resolveCanonicalRootDirectorySync(
      backupsDir,
      expectedParentCanonicalPath: canonicalParent.path,
    );
  }

  /// Resolves app-private export directory for non-Android targets or the
  /// documented API 23-28 SAF-unavailable fallback (`Reports`, `Exports`).
  ///
  /// Never points to `/storage/emulated/0/Documents` and never aliases
  /// [getAppBackupsDirectory].
  static Future<Directory> getPrivateExportsDirectory({
    String subFolder = '',
    Directory? baseDirectoryOverride,
  }) async {
    final baseFolderName = await getExportBaseFolderName();
    final cleanSubFolder = sanitizeSubFolder(subFolder);
    late final Directory baseDir;
    if (baseDirectoryOverride != null) {
      baseDir = baseDirectoryOverride;
    } else {
      try {
        baseDir = await getApplicationDocumentsDirectory();
      } catch (_) {
        baseDir = Directory('.');
      }
    }

    final canonicalBase = _resolveCanonicalRootDirectorySync(baseDir);
    final suffix = cleanSubFolder.isNotEmpty
        ? '$baseFolderName${Platform.pathSeparator}${cleanSubFolder.replaceAll('/', Platform.pathSeparator)}'
        : baseFolderName;
    final targetDir =
        Directory('${canonicalBase.path}${Platform.pathSeparator}$suffix');
    return _resolveCanonicalRootDirectorySync(
      targetDir,
      expectedParentCanonicalPath: canonicalBase.path,
    );
  }

  /// Resolves the ephemeral cache directory used to stage local copies for
  /// `share_plus` when an export only has a `content://` URI.
  static Future<Directory> getShareStagingDirectory({
    Directory? tempDirectoryOverride,
  }) async {
    final Directory tempDir =
        tempDirectoryOverride ?? await getTemporaryDirectory();
    final canonicalTemp = _resolveCanonicalRootDirectorySync(tempDir);
    final shareDir =
        Directory('${canonicalTemp.path}${Platform.pathSeparator}export_share');
    return _resolveCanonicalRootDirectorySync(
      shareDir,
      expectedParentCanonicalPath: canonicalTemp.path,
    );
  }

  /// Validates that [candidatePath] is a real filesystem path (not a URI or
  /// symlink) strictly contained within [rootDirectory].
  static Future<String> resolveValidatedPathInDirectory({
    required String candidatePath,
    required Directory rootDirectory,
    bool mustExist = true,
  }) async {
    final trimmed = candidatePath.trim();
    final lower = trimmed.toLowerCase();
    if (trimmed.isEmpty ||
        trimmed.contains('\u0000') ||
        lower.startsWith('content://') ||
        lower.startsWith('file://')) {
      throw FileSystemException(
        'Invalid filesystem path (URI or empty path not permitted).',
        candidatePath,
      );
    }

    final canonicalRoot =
        _resolveCanonicalRootDirectorySync(rootDirectory).path;

    final candidateType = FileSystemEntity.typeSync(
      trimmed,
      followLinks: false,
    );
    if (candidateType == FileSystemEntityType.link) {
      throw FileSystemException(
        'Symbolic links are not permitted in managed storage.',
        candidatePath,
      );
    }
    if (candidateType == FileSystemEntityType.directory) {
      throw FileSystemException(
        'Expected a file path, found a directory.',
        candidatePath,
      );
    }

    if (mustExist) {
      if (candidateType == FileSystemEntityType.notFound) {
        throw FileSystemException('Backup file not found.', candidatePath);
      }
      final canonicalFile = File(trimmed).resolveSymbolicLinksSync();
      if (!_isStrictChildPath(canonicalFile, canonicalRoot)) {
        throw FileSystemException(
          'Access denied: path is outside the managed storage directory.',
          candidatePath,
        );
      }
      return canonicalFile;
    }

    // Write target: verify filename and canonical parent containment.
    final file = File(trimmed);
    final baseName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : trimmed.split(Platform.pathSeparator).last;
    validateFileName(baseName);

    final parentType = FileSystemEntity.typeSync(
      file.parent.path,
      followLinks: false,
    );
    if (parentType == FileSystemEntityType.link ||
        parentType == FileSystemEntityType.notFound) {
      throw FileSystemException(
        'Invalid or missing target storage directory.',
        candidatePath,
      );
    }
    final canonicalParent = file.parent.resolveSymbolicLinksSync();
    if (!_isSameNormalizedPath(canonicalParent, canonicalRoot) &&
        !_isStrictChildPath(canonicalParent, canonicalRoot)) {
      throw FileSystemException(
        'Access denied: target directory is outside the managed storage directory.',
        candidatePath,
      );
    }
    return '$canonicalParent${Platform.pathSeparator}$baseName';
  }

  /// Writes an app-managed `.attendiq` backup inside the app-private `backups/`
  /// directory.
  static Future<ExportSaveResult> saveAppPrivateBackup({
    required String fileName,
    required List<int> bytes,
    Directory? baseDirectoryOverride,
    Directory? backupsDirOverride,
  }) async {
    final cleanFileName = validateFileName(fileName);
    final backupsDir = await getAppBackupsDirectory(
      baseDirectoryOverride: baseDirectoryOverride,
      backupsDirOverride: backupsDirOverride,
    );
    final targetPath = await resolveValidatedPathInDirectory(
      candidatePath:
          '${backupsDir.path}${Platform.pathSeparator}$cleanFileName',
      rootDirectory: backupsDir,
      mustExist: false,
    );

    final file = File(targetPath);
    await file.writeAsBytes(bytes, flush: true);

    return ExportSaveResult(
      localFilePath: targetPath,
      shareableFilePath: targetPath,
      displayPath: 'App Storage/Backups/$cleanFileName',
      fileName: cleanFileName,
      subFolder: 'Backups',
    );
  }

  /// Stages an ephemeral local copy in `cacheDir/export_share/` for sharing
  /// `content://`-backed exports via `share_plus`.
  static Future<String> stageShareableFile({
    required String fileName,
    required List<int> bytes,
    Directory? tempDirectoryOverride,
  }) async {
    final cleanFileName = validateFileName(fileName);
    final stagingDir = await getShareStagingDirectory(
      tempDirectoryOverride: tempDirectoryOverride,
    );

    // Keep cache bounded by clearing prior ephemeral share files.
    await for (final entity in stagingDir.list(followLinks: false)) {
      if (entity is File) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }

    final targetPath = await resolveValidatedPathInDirectory(
      candidatePath:
          '${stagingDir.path}${Platform.pathSeparator}$cleanFileName',
      rootDirectory: stagingDir,
      mustExist: false,
    );
    final stagedFile = File(targetPath);
    await stagedFile.writeAsBytes(bytes, flush: true);
    return targetPath;
  }

  /// Returns user-friendly folder path string for the UI.
  static Future<String> getDisplayFolderPath({String subFolder = ''}) async {
    final cleanSub = sanitizeSubFolder(subFolder);
    if (cleanSub.toLowerCase() == 'backups') {
      return 'App Storage/Backups';
    }
    final baseFolder = await getExportBaseFolderName();
    final pathSuffix =
        cleanSub.isNotEmpty ? '$baseFolder/$cleanSub' : baseFolder;
    if (Platform.isAndroid) {
      return 'Internal Storage/Documents/$pathSuffix';
    }
    return 'Documents/$pathSuffix';
  }

  /// Saves binary/string content to user-accessible public storage:
  /// - Android 10+ (API 29+): `MediaStore.Files` returning a real `content://` URI.
  /// - Android 6-9 (API 23-28): SAF `ACTION_CREATE_DOCUMENT` (when
  ///   [allowDocumentPicker] is `true`), or documented app-private fallback if
  ///   SAF is unavailable on the device.
  /// - Non-Android platforms: app-private export directory.
  static Future<ExportSaveResult> savePublicExportFile({
    required String fileName,
    required List<int> bytes,
    required String subFolder,
    required String mimeType,
    bool allowDocumentPicker = true,
    bool stageShareCopy = true,
    bool? isAndroidOverride,
    Directory? privateExportBaseDirOverride,
    Directory? tempDirectoryOverride,
  }) async {
    final cleanFileName = validateFileName(fileName);
    final cleanSubFolder = sanitizeSubFolder(subFolder);
    final isBeta = await isBetaApp();
    final isAndroid = isAndroidOverride ?? (Platform.isAndroid && !kIsWeb);

    if (isAndroid) {
      final response = await _storageChannel.invokeMapMethod<String, dynamic>(
        'saveToPublicStorage',
        <String, dynamic>{
          'fileName': cleanFileName,
          'bytes': Uint8List.fromList(bytes),
          'subFolder': cleanSubFolder,
          'mimeType': mimeType,
          'isBeta': isBeta,
          'allowDocumentPicker': allowDocumentPicker,
        },
      );

      if (response != null) {
        final wasCancelled = response['cancelled'] == true;
        if (wasCancelled) {
          return ExportSaveResult(
            displayPath: '',
            fileName: cleanFileName,
            subFolder: cleanSubFolder,
            wasCancelled: true,
          );
        }

        final skippedPicker = response['skippedDocumentPicker'] == true;
        if (skippedPicker) {
          return ExportSaveResult(
            displayPath: '',
            fileName: cleanFileName,
            subFolder: cleanSubFolder,
          );
        }

        final unsupportedSaf = response['unsupportedSaf'] == true;
        if (!unsupportedSaf) {
          final contentUri = (response['contentUri'] as String?)?.trim();
          if (contentUri == null || contentUri.isEmpty) {
            throw const FileSystemException(
              'Android storage channel returned an empty content URI.',
            );
          }

          final rawDisplayName = (response['displayName'] as String?)?.trim();
          final resolvedName =
              (rawDisplayName != null && rawDisplayName.isNotEmpty)
                  ? validateFileName(rawDisplayName)
                  : cleanFileName;
          final relativePath = (response['relativePath'] as String?)?.trim();
          final displayPath = (relativePath != null && relativePath.isNotEmpty)
              ? 'Internal Storage/$relativePath/$resolvedName'
              : resolvedName;

          final String? sharePath = stageShareCopy
              ? await stageShareableFile(
                  fileName: resolvedName,
                  bytes: bytes,
                  tempDirectoryOverride: tempDirectoryOverride,
                )
              : null;

          return ExportSaveResult(
            contentUri: contentUri,
            shareableFilePath: sharePath,
            displayPath: displayPath,
            fileName: resolvedName,
            subFolder: cleanSubFolder,
          );
        }
      }
    }

    // Non-Android platforms or Android 6-9 devices lacking a SAF document picker.
    final targetDir = await getPrivateExportsDirectory(
      subFolder: cleanSubFolder,
      baseDirectoryOverride: privateExportBaseDirOverride,
    );
    final targetPath = await resolveValidatedPathInDirectory(
      candidatePath: '${targetDir.path}${Platform.pathSeparator}$cleanFileName',
      rootDirectory: targetDir,
      mustExist: false,
    );
    final file = File(targetPath);
    await file.writeAsBytes(bytes, flush: true);

    final baseFolder = await getExportBaseFolderName();
    final suffix = cleanSubFolder.isNotEmpty
        ? '$baseFolder/$cleanSubFolder/$cleanFileName'
        : '$baseFolder/$cleanFileName';

    return ExportSaveResult(
      localFilePath: targetPath,
      shareableFilePath: targetPath,
      displayPath: 'App Storage/$suffix',
      fileName: cleanFileName,
      subFolder: cleanSubFolder,
    );
  }

  /// Opens a public `content://` export URI in an external Android viewer.
  static Future<bool> openExportUri({
    required String contentUri,
    required String mimeType,
    bool? isAndroidOverride,
  }) async {
    final trimmed = contentUri.trim();
    if (!trimmed.toLowerCase().startsWith('content://')) {
      return false;
    }
    final isAndroid = isAndroidOverride ?? (Platform.isAndroid && !kIsWeb);
    if (!isAndroid) {
      return false;
    }
    try {
      final bool? success = await _storageChannel.invokeMethod<bool>(
        'openExportUri',
        <String, dynamic>{
          'contentUri': trimmed,
          'mimeType': mimeType,
        },
      );
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Lists all `.attendiq` backup files in the app-private `backups/`
  /// directory, sorted newest first.
  static Future<List<BackupFileItem>> listBackupFiles({
    Directory? baseDirectoryOverride,
    Directory? backupsDirOverride,
  }) async {
    try {
      final backupsDir = await getAppBackupsDirectory(
        baseDirectoryOverride: baseDirectoryOverride,
        backupsDirOverride: backupsDirOverride,
      );
      final List<BackupFileItem> items = [];

      await for (final entity in backupsDir.list(followLinks: false)) {
        final type = await FileSystemEntity.type(
          entity.path,
          followLinks: false,
        );
        if (type != FileSystemEntityType.file) {
          continue;
        }
        if (!entity.path.toLowerCase().endsWith('.attendiq')) {
          continue;
        }

        final String validatedPath;
        try {
          validatedPath = await resolveValidatedPathInDirectory(
            candidatePath: entity.path,
            rootDirectory: backupsDir,
            mustExist: true,
          );
        } catch (_) {
          continue;
        }

        final file = File(validatedPath);
        final stat = await file.stat();
        final fileName = validatedPath.split(Platform.pathSeparator).last;
        items.add(
          BackupFileItem(
            fileName: fileName,
            filePath: validatedPath,
            modifiedDate: stat.modified,
            sizeBytes: stat.size,
          ),
        );
      }

      items.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
      return items;
    } catch (_) {
      return [];
    }
  }

  static Directory _resolveCanonicalRootDirectorySync(
    Directory targetDir, {
    String? expectedParentCanonicalPath,
  }) {
    final entityType = FileSystemEntity.typeSync(
      targetDir.path,
      followLinks: false,
    );
    if (entityType == FileSystemEntityType.link) {
      throw FileSystemException(
        'Storage directory cannot be a symbolic link.',
        targetDir.path,
      );
    }
    if (entityType == FileSystemEntityType.file) {
      throw FileSystemException(
        'Storage directory path is occupied by a file.',
        targetDir.path,
      );
    }
    if (entityType == FileSystemEntityType.notFound) {
      targetDir.createSync(recursive: true);
    }

    final canonicalPath = targetDir.resolveSymbolicLinksSync();
    if (expectedParentCanonicalPath != null &&
        !_isStrictChildPath(canonicalPath, expectedParentCanonicalPath)) {
      throw FileSystemException(
        'Storage directory escaped parent boundary.',
        targetDir.path,
      );
    }
    return Directory(canonicalPath);
  }

  static String _normalizeForComparison(String rawPath) {
    var normalized = rawPath;
    final sep = Platform.pathSeparator;
    while (normalized.length > 1 && normalized.endsWith(sep)) {
      // Preserve Windows drive root like `C:\`.
      if (Platform.isWindows &&
          normalized.length == 3 &&
          normalized[1] == ':') {
        break;
      }
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static bool _isSameNormalizedPath(String a, String b) {
    return _normalizeForComparison(a) == _normalizeForComparison(b);
  }

  static bool _isStrictChildPath(String childPath, String parentPath) {
    final normChild = _normalizeForComparison(childPath);
    final normParent = _normalizeForComparison(parentPath);
    final sep = Platform.pathSeparator;
    final prefix = normParent.endsWith(sep) ? normParent : '$normParent$sep';
    return normChild.startsWith(prefix);
  }
}
