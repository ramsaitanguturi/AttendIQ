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
      ),
    );
  }

  @override
  State<ExportSuccessDialog> createState() => _ExportSuccessDialogState();
}

class _ExportSuccessDialogState extends State<ExportSuccessDialog> {
  late ExportSaveResult _currentResult;
  bool _isSavingCopy = false;

  @override
  void initState() {
    super.initState();
    _currentResult = widget.exportResult;
  }

  Future<void> _handleShare(BuildContext context) async {
    try {
      final sharePath = _currentResult.effectiveSharePath;
      if (sharePath != null &&
          !sharePath.trim().toLowerCase().startsWith('content://') &&
          await File(sharePath).exists()) {
        final isBeta = await BackupPathHelper.isBetaApp();
        final appName = isBeta ? 'AttendIQ Beta' : 'AttendIQ';
        final shareHandler = widget.shareFilesOverride;
        if (shareHandler != null) {
          await shareHandler(
            [XFile(sharePath, mimeType: widget.mimeType)],
            text: '$appName File Export',
            subject: _currentResult.fileName,
          );
          return;
        }
        await Share.shareXFiles(
          [XFile(sharePath, mimeType: widget.mimeType)],
          text: '$appName File Export',
          subject: _currentResult.fileName,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File path not found for sharing.'),
              backgroundColor: AppColors.attendanceLow,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  Future<void> _handleOpenFile(BuildContext context) async {
    final uri = _currentResult.contentUri;
    if (uri == null || uri.isEmpty) return;

    try {
      final opened = await BackupPathHelper.openExportUri(
        contentUri: uri,
        mimeType: widget.mimeType,
        isAndroidOverride: widget.isAndroidOverride,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved to ${_currentResult.displayPath}. Open Files app to view.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (_) {}
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

  String _subtitleText() {
    if (_currentResult.hasContentUri && _currentResult.hasLocalFile) {
      return 'Backup saved to app storage and public external storage:';
    }
    if (_currentResult.hasContentUri) {
      return 'File has been saved to public storage:';
    }
    return 'File has been saved to app storage:';
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
            if (_currentResult.hasContentUri)
              OutlinedButton.icon(
                onPressed: () => _handleOpenFile(context),
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
              )
            else if (widget.onSavePublicCopy != null)
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
                label: const Text(
                  'Share File',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
