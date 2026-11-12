import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../backup/backup_path_helper.dart';
import '../backup/backup_service.dart';
import '../theme/colors.dart';

class ExportSuccessDialog extends StatefulWidget {
  final String title;
  final ExportSaveResult exportResult;
  final String mimeType;
  final Future<ExportSaveResult> Function()? onSavePublicCopy;
  final ShareFilesHandler? shareFilesOverride;
  final bool? isAndroidOverride;

  const ExportSuccessDialog({
    super.key,
    required this.title,
    required this.exportResult,
    required this.mimeType,
    this.onSavePublicCopy,
    @visibleForTesting this.shareFilesOverride,
    @visibleForTesting this.isAndroidOverride,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required ExportSaveResult exportResult,
    required String mimeType,
    Future<ExportSaveResult> Function()? onSavePublicCopy,
    @visibleForTesting ShareFilesHandler? shareFilesOverride,
    @visibleForTesting bool? isAndroidOverride,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ExportSuccessDialog(
        title: title,
        exportResult: exportResult,
        mimeType: mimeType,
        onSavePublicCopy: onSavePublicCopy,
        shareFilesOverride: shareFilesOverride,
        isAndroidOverride: isAndroidOverride,
      ),
    );
  }

  @override
  State<ExportSuccessDialog> createState() => _ExportSuccessDialogState();
}

class _ExportSuccessDialogState extends State<ExportSuccessDialog> {
  late ExportSaveResult _currentResult;
  bool _isSavingCopy = false;
  bool _isOpeningFile = false;

  @override
  void initState() {
    super.initState();
    _currentResult = widget.exportResult;
  }

  static Future<void> _shareExportedFile({
    required ExportSaveResult result,
    required String mimeType,
    required ScaffoldMessengerState? messenger,
    ShareFilesHandler? shareHandler,
  }) async {
    try {
      final sharePath = result.effectiveSharePath;
      if (sharePath != null &&
          !sharePath.trim().toLowerCase().startsWith('content://') &&
          await File(sharePath).exists()) {
        final isBeta = await BackupPathHelper.isBetaApp();
        final appName = isBeta ? 'AttendIQ Beta' : 'AttendIQ';
        final files = [XFile(sharePath, mimeType: mimeType)];
        if (shareHandler != null) {
          await shareHandler(
            files,
            text: '$appName File Export',
            subject: result.fileName,
          );
          return;
        }
        await Share.shareXFiles(
          files,
          text: '$appName File Export',
          subject: result.fileName,
        );
      } else if (messenger != null && messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('File path not found for sharing.'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    } catch (e) {
      if (messenger != null && messenger.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  Future<void> _handleShare(BuildContext context) async {
    await _shareExportedFile(
      result: _currentResult,
      mimeType: widget.mimeType,
      messenger: ScaffoldMessenger.maybeOf(context),
      shareHandler: widget.shareFilesOverride,
    );
  }

  Future<void> _handleOpenFile(BuildContext context) async {
    final uri = _currentResult.contentUri;
    if (uri == null || uri.isEmpty || _isOpeningFile) return;

    setState(() {
      _isOpeningFile = true;
    });

    try {
      final openResult = await BackupPathHelper.openExportUriWithResult(
        contentUri: uri,
        mimeType: widget.mimeType,
        isAndroidOverride: widget.isAndroidOverride,
      );
      if (!openResult.opened && mounted) {
        _showOpenFallbackSnackBar(openResult);
      }
    } catch (e) {
      if (mounted) {
        _showOpenFallbackSnackBar(
          OpenExportUriResult.failure(
            reason: OpenExportFailureReason.channelError,
            errorCode: 'OPEN_FAILED',
            message: e.toString(),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningFile = false;
        });
      }
    }
  }

  void _showOpenFallbackSnackBar(OpenExportUriResult result) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final currentResult = _currentResult;
    final mimeType = widget.mimeType;
    final shareHandler = widget.shareFilesOverride;
    final hasShareable = currentResult.effectiveSharePath != null;
    final String message;
    final Color backgroundColor;

    switch (result.reason) {
      case OpenExportFailureReason.noCompatibleApp:
        message = hasShareable
            ? 'No compatible app found to open ${currentResult.fileName}. '
                'Saved to ${currentResult.displayPath}. '
                'Use Share or open via Files app.'
            : 'No compatible app found to open ${currentResult.fileName}. '
                'Saved to ${currentResult.displayPath}. '
                'Open Files app to view.';
        backgroundColor = AppColors.darkSurface;
        break;
      case OpenExportFailureReason.activityLaunchFailed:
      case OpenExportFailureReason.invalidUri:
      case OpenExportFailureReason.channelError:
        message = hasShareable
            ? 'Unable to open ${currentResult.fileName} directly. '
                'Saved to ${currentResult.displayPath}. '
                'Use Share or open via Files app.'
            : 'Unable to open ${currentResult.fileName} directly. '
                'Saved to ${currentResult.displayPath}. '
                'Open Files app to view.';
        backgroundColor = AppColors.attendanceLow;
        break;
      case OpenExportFailureReason.unsupportedPlatform:
        message =
            'Saved to ${currentResult.displayPath}. Open Files app to view.';
        backgroundColor = AppColors.darkSurface;
        break;
      case OpenExportFailureReason.none:
        return;
    }

    // Dismiss the modal dialog so the fallback SnackBar and its Share action
    // are rendered above any barrier and remain directly interactive.
    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        action: hasShareable
            ? SnackBarAction(
                label: 'Share',
                textColor: AppColors.primary,
                onPressed: () {
                  _shareExportedFile(
                    result: currentResult,
                    mimeType: mimeType,
                    messenger: messenger,
                    shareHandler: shareHandler,
                  );
                },
              )
            : null,
      ),
    );
  }

  Future<void> _handleSavePublicCopy(BuildContext context) async {
    final handler = widget.onSavePublicCopy;
    if (handler == null || _isSavingCopy) return;
    setState(() {
      _isSavingCopy = true;
    });
    try {
      final saved = await handler();
      if (!mounted) return;
      if (!saved.wasCancelled && (saved.hasContentUri || saved.hasLocalFile)) {
        setState(() {
          _currentResult = saved;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved copy to ${saved.displayPath}'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save copy failed: $e'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingCopy = false;
        });
      }
    }
  }

  bool get _isAttendIqBackup =>
      _currentResult.fileName.trim().toLowerCase().endsWith('.attendiq');

  String _subtitleText() {
    if (_currentResult.hasContentUri && _currentResult.hasLocalFile) {
      return 'Backup saved to app storage and public external storage:';
    }
    if (_currentResult.hasContentUri) {
      return 'File has been saved to public storage:';
    }
    return 'File has been saved to app storage:';
  }

  String _resolveBackupSizeLabel() {
    final candidatePath = _currentResult.effectiveSharePath;
    if (candidatePath != null &&
        !candidatePath.trim().toLowerCase().startsWith('content://')) {
      try {
        final file = File(candidatePath);
        if (file.existsSync()) {
          return BackupPathHelper.formatFileSize(file.lengthSync());
        }
      } catch (_) {
        // Fall through to storage fallback text if size lookup fails.
      }
    }
    return 'Available in device storage';
  }

  Future<void> _showBackupDetailsDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sizeLabel = _resolveBackupSizeLabel();
    final locationLines = <String>[
      _currentResult.displayPath,
      if (_currentResult.hasLocalFile &&
          _currentResult.localFilePath != _currentResult.displayPath)
        'App Storage: ${_currentResult.localFilePath}',
    ].join('\n');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(child: Text('Backup Details')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackupDetailRow(
                label: 'File Name',
                value: _currentResult.fileName,
              ),
              const SizedBox(height: 10),
              const _BackupDetailRow(
                label: 'Format',
                value: 'AttendIQ Backup (.attendiq JSON)',
              ),
              const SizedBox(height: 10),
              _BackupDetailRow(label: 'Size', value: sizeLabel),
              const SizedBox(height: 10),
              _BackupDetailRow(label: 'Location', value: locationLines),
              const SizedBox(height: 14),
              const Text(
                'This backup is formatted specifically for AttendIQ. '
                'To restore it, select it from Backup Manager or tap '
                'Import Backup / Data File.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _subtitleText(),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentResult.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentResult.displayPath,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!_currentResult.hasContentUri &&
                widget.onSavePublicCopy != null)
              OutlinedButton.icon(
                onPressed:
                    _isSavingCopy ? null : () => _handleSavePublicCopy(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.save_alt,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  _isSavingCopy ? 'Saving...' : 'Save Copy to Device',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              )
            else if (_isAttendIqBackup)
              OutlinedButton.icon(
                onPressed: () => _showBackupDetailsDialog(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Backup Details',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              )
            else if (_currentResult.hasContentUri)
              OutlinedButton.icon(
                onPressed:
                    _isOpeningFile ? null : () => _handleOpenFile(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Open File',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            if (_currentResult.effectiveSharePath != null)
              ElevatedButton.icon(
                onPressed: () => _handleShare(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.share, size: 18, color: Colors.black),
                label: Text(
                  _isAttendIqBackup ? 'Share Backup' : 'Share File',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BackupDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _BackupDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
