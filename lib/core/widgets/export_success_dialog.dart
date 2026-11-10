import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../backup/backup_path_helper.dart';
import '../theme/colors.dart';

class ExportSuccessDialog extends StatelessWidget {
  final String title;
  final String filePath;
  final String fileName;
  final String mimeType;

  const ExportSuccessDialog({
    super.key,
    required this.title,
    required this.filePath,
    required this.fileName,
    required this.mimeType,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ExportSuccessDialog(
        title: title,
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
      ),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final isBeta = await BackupPathHelper.isBetaApp();
        final appName = isBeta ? 'AttendIQ Beta' : 'AttendIQ';
        await Share.shareXFiles(
          [XFile(filePath, mimeType: mimeType)],
          text: '$appName File Export',
          subject: fileName,
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

  Future<void> _handleOpenFolder(BuildContext context) async {
    try {
      // Determine subfolder if any
      String subFolder = '';
      if (filePath.contains('/Backups/') || filePath.contains('\\Backups\\')) {
        subFolder = 'Backups';
      } else if (filePath.contains('/Reports/') || filePath.contains('\\Reports\\')) {
        subFolder = 'Reports';
      } else if (filePath.contains('/Exports/') || filePath.contains('\\Exports\\')) {
        subFolder = 'Exports';
      }

      final opened = await BackupPathHelper.openExportFolder(subFolder: subFolder);
      if (!opened && context.mounted) {
        final displayPath = await BackupPathHelper.getDisplayFolderPath(subFolder: subFolder);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to $displayPath. Open Files app to view.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (_) {}
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
            child: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'File has been saved to public external storage:',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  filePath,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => _handleOpenFolder(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.folder_open, size: 18, color: AppColors.primary),
              label: const Text('Open Folder', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _handleShare(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.share, size: 18, color: Colors.black),
              label: const Text('Share File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}
