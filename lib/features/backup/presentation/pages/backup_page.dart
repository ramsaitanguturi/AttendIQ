import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/backup/backup_importer.dart';
import '../../../../core/backup/backup_path_helper.dart';
import '../../../../core/backup/backup_providers.dart';
import '../../../../core/backup/backup_scheduler.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/export_success_dialog.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isLoadingFileList = true;
  List<BackupFileItem> _backupFiles = [];
  String _displayFolderPath = 'App Storage/Backups';
  String? _statusMessage;
  bool _statusIsError = false;
  final TextEditingController _importJsonController = TextEditingController();

  String _formatErrorMessage(Object error) {
    if (error is FormatException) {
      return error.message;
    }
    if (error is FileSystemException) {
      final osMsg = error.osError?.message;
      return osMsg != null && osMsg.isNotEmpty
          ? '${error.message} ($osMsg)'
          : error.message;
    }
    return '$error';
  }

  @override
  void initState() {
    super.initState();
    _refreshBackupList();
  }

  @override
  void dispose() {
    _importJsonController.dispose();
    super.dispose();
  }

  Future<void> _refreshBackupList() async {
    if (!mounted) return;
    setState(() {
      _isLoadingFileList = true;
    });

    try {
      final service = ref.read(backupServiceProvider);
      final files = await service.listBackups();
      final folderPath =
          await BackupPathHelper.getDisplayFolderPath(subFolder: 'Backups');
      if (mounted) {
        setState(() {
          _backupFiles = files;
          _displayFolderPath = folderPath;
          _isLoadingFileList = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingFileList = false;
        });
      }
    }
  }

  Future<void> _handleExportBackup() async {
    setState(() {
      _isExporting = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final service = ref.read(backupServiceProvider);
      final activeSemester =
          await ref.read(semesterRepositoryProvider).getActiveSemester();
      final result = await service.exportToFileResult(
        semesterName: activeSemester?.name,
      );
      final now = DateTime.now();

      // Update last backup date in settings
      await ref
          .read(settingsControllerProvider.notifier)
          .updateLastBackupDate(now);

      await _refreshBackupList();
      if (!mounted) return;

      setState(() {
        _statusMessage =
            'Backup created successfully!\nSaved to: ${result.displayPath}';
        _statusIsError = false;
      });

      await ExportSuccessDialog.show(
        context: context,
        title: 'Backup exported successfully',
        exportResult: result,
        mimeType: 'application/octet-stream',
        onSavePublicCopy: (!result.hasContentUri && result.hasLocalFile)
            ? () => service.saveBackupCopyToPublicStorage(result.localFilePath!)
            : null,
      );
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        setState(() {
          _statusMessage = 'Export failed: $errMsg';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _handleExportJsonData() async {
    setState(() {
      _isExporting = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final service = ref.read(backupServiceProvider);
      final activeSemester =
          await ref.read(semesterRepositoryProvider).getActiveSemester();
      final result = await service.exportDataJsonResult(
        semesterName: activeSemester?.name,
      );
      if (!mounted || result.wasCancelled) return;

      setState(() {
        _statusMessage =
            'JSON Data exported successfully!\nSaved to: ${result.displayPath}';
        _statusIsError = false;
      });

      await ExportSuccessDialog.show(
        context: context,
        title: 'JSON Data exported successfully',
        exportResult: result,
        mimeType: 'application/json',
      );
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        setState(() {
          _statusMessage = 'Export failed: $errMsg';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _handlePickImportFile() async {
    if (_isImporting) return;
    setState(() {
      _isImporting = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final service = ref.read(backupServiceProvider);
      final picked = await service.pickImportFile();
      if (!mounted) return;

      if (picked != null) {
        await _showImportStrategyDialog(picked.content);
      }
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to read selected file: $errMsg';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read selected file: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _handleRestoreFile(BackupFileItem fileItem) async {
    if (_isImporting) return;
    setState(() {
      _isImporting = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final service = ref.read(backupServiceProvider);
      await service.validateManagedBackupFile(
        fileItem.filePath,
        strategy: null,
      );
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        setState(() {
          _statusMessage = 'Backup validation error: $errMsg';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup validation error: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Restore Backup'),
          content: Text(
            'Restore from "${fileItem.fileName}"?\n\n'
            'Choose Replace to overwrite all current data, or Merge to combine records.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _performFileImport(fileItem.filePath, ImportStrategy.merge);
              },
              child: const Text('Merge Data'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _performFileImport(fileItem.filePath, ImportStrategy.replace);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.attendanceLow,
              ),
              child: const Text(
                'Replace Data',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performFileImport(
    String filePath,
    ImportStrategy strategy,
  ) async {
    setState(() {
      _isImporting = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final service = ref.read(backupServiceProvider);
      await service.importManagedBackupFile(filePath, strategy: strategy);
      if (!mounted) return;
      ref.invalidate(hasActiveSemesterProvider);
      ref.invalidate(activeSemesterProvider);
      ref.invalidate(allSemestersProvider);
      await _refreshBackupList();
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Import completed successfully (${strategy == ImportStrategy.replace ? "Replaced" : "Merged"})!';
        _statusIsError = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database restored successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        setState(() {
          _statusMessage = 'Restore failed: $errMsg';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _handleShareFile(BackupFileItem fileItem) async {
    try {
      final service = ref.read(backupServiceProvider);
      await service.shareBackupFile(fileItem.filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share backup: $e'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteFile(BackupFileItem fileItem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text(
          'Are you sure you want to delete "${fileItem.fileName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.attendanceLow,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final service = ref.read(backupServiceProvider);
      final success = await service.deleteBackupFile(fileItem.filePath);
      if (!mounted) return;
      if (success) {
        await _refreshBackupList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup file deleted successfully.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete backup file.'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  Future<void> _handleSavePublicCopy(BackupFileItem fileItem) async {
    try {
      final service = ref.read(backupServiceProvider);
      final result =
          await service.saveBackupCopyToPublicStorage(fileItem.filePath);
      if (!mounted || result.wasCancelled) return;

      await ExportSuccessDialog.show(
        context: context,
        title: 'Backup copy saved',
        exportResult: result,
        mimeType: 'application/octet-stream',
      );
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save backup copy: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  Future<void> _showImportTextDialog() async {
    _importJsonController.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Import Backup JSON Text'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paste your .attendiq JSON backup content below:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _importJsonController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText:
                        '{\n  "metadata": {...},\n  "semesters": [...]\n}',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showImportStrategyDialog(_importJsonController.text.trim());
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImportStrategyDialog(String jsonString) async {
    if (jsonString.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _statusMessage = 'No backup content provided.';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No backup content provided.')),
        );
      }
      return;
    }

    try {
      final service = ref.read(backupServiceProvider);
      await service.validateBackupPayload(
        jsonString,
        strategy: null,
      );
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        setState(() {
          _statusMessage = 'Backup validation error: $errMsg';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup validation error: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Restore Mode'),
          content: const Text(
            'Replace Data will overwrite all current attendance, timetable, and settings.\n\nMerge Data will combine backup items with existing records.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _performImportString(jsonString, ImportStrategy.merge);
              },
              child: const Text('Merge Data'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _performImportString(jsonString, ImportStrategy.replace);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.attendanceLow,
              ),
              child: const Text(
                'Replace Existing Data',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performImportString(
    String jsonString,
    ImportStrategy strategy,
  ) async {
    setState(() {
      _isImporting = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final service = ref.read(backupServiceProvider);
      await service.importFromBackupString(jsonString, strategy: strategy);
      if (!mounted) return;
      ref.invalidate(hasActiveSemesterProvider);
      ref.invalidate(activeSemesterProvider);
      ref.invalidate(allSemestersProvider);
      await _refreshBackupList();
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Import completed successfully (${strategy == ImportStrategy.replace ? "Replaced" : "Merged"})!';
        _statusIsError = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database restored successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      final errMsg = _formatErrorMessage(e);
      if (mounted) {
        setState(() {
          _statusMessage = 'Import failed: $errMsg';
          _statusIsError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $errMsg'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        data: (settings) {
          final isAutoBackupEnabled = settings.enableAutoBackup;
          final lastBackup = settings.lastBackupDate;
          final nextScheduled = isAutoBackupEnabled
              ? BackupScheduler.getNextScheduledBackup(
                  fromDate: lastBackup ?? DateTime.now(),
                  targetWeekday: settings.autoBackupDay,
                  targetHour: settings.autoBackupHour,
                )
              : null;

          final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / Storage Location Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.folder_special_outlined,
                              color: AppColors.primary, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Backup Export Location',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sd_storage,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _displayFolderPath,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'App-managed backups and automatic backups are stored safely in app storage. Reports, JSON exports, and optional public copies are saved via Android system storage without broad permissions. To restore older backups from Documents, use Import Backup / Data File below.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Automatic Backup Settings UI
                Text(
                  'Automatic Weekly Backup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Enable Automatic Backup',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'Runs automatically once every week (Sunday at 2:00 AM)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        value: isAutoBackupEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (enabled) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .updateEnableAutoBackup(enabled);
                          BackupScheduler.scheduleOrCancelAutoBackup(enabled);
                        },
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Last Backup Date:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            lastBackup != null
                                ? dateFormat.format(lastBackup)
                                : 'Never',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Next Scheduled Backup:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            nextScheduled != null
                                ? dateFormat.format(nextScheduled)
                                : 'Disabled',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isAutoBackupEnabled
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Export & Import Quick Actions
                Text(
                  'Export & Import Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isExporting ? null : _handleExportBackup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.download),
                            label: const Text(
                              'Export Backup (.attendiq)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                _isExporting ? null : _handleExportJsonData,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.code,
                                color: AppColors.primary),
                            label: const Text(
                              'Export Data (.json)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isImporting ? null : _handlePickImportFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          foregroundColor:
                              isDark ? Colors.white : Colors.black87,
                          side: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isImporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.folder_open_outlined,
                                color: AppColors.primary),
                        label: const Text(
                          'Import Backup / Data File (Drive, Downloads, Documents)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _showImportTextDialog,
                        icon: const Icon(Icons.paste_outlined,
                            size: 14, color: Colors.grey),
                        label: const Text(
                          'Paste raw JSON string instead',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Backup Manager Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Backup Manager',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _refreshBackupList,
                      tooltip: 'Refresh Backup List',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: _isLoadingFileList
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _backupFiles.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'No backup files (.attendiq) found in $_displayFolderPath.\nTo restore older backups from Documents, use Import Backup / Data File.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _backupFiles.length,
                              separatorBuilder: (ctx, idx) => Divider(
                                height: 1,
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              itemBuilder: (ctx, idx) {
                                final fileItem = _backupFiles[idx];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.15),
                                    child: const Icon(Icons.insert_drive_file,
                                        color: AppColors.primary, size: 22),
                                  ),
                                  title: Text(
                                    fileItem.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    '${dateFormat.format(fileItem.modifiedDate)} • ${fileItem.formattedSize}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'restore') {
                                        _handleRestoreFile(fileItem);
                                      } else if (value == 'share') {
                                        _handleShareFile(fileItem);
                                      } else if (value == 'save_copy') {
                                        _handleSavePublicCopy(fileItem);
                                      } else if (value == 'delete') {
                                        _handleDeleteFile(fileItem);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'restore',
                                        child: Row(
                                          children: [
                                            Icon(Icons.restore,
                                                size: 18,
                                                color: AppColors.primary),
                                            SizedBox(width: 8),
                                            Text('Restore'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Row(
                                          children: [
                                            Icon(Icons.share,
                                                size: 18, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Share'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'save_copy',
                                        child: Row(
                                          children: [
                                            Icon(Icons.save_alt,
                                                size: 18,
                                                color: AppColors.primary),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Save Copy to Device',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline,
                                                size: 18,
                                                color: AppColors.attendanceLow),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),

                if (_statusMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (_statusIsError
                              ? AppColors.attendanceLow
                              : AppColors.primary)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_statusIsError
                                ? AppColors.attendanceLow
                                : AppColors.primary)
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _statusIsError ? AppColors.attendanceLow : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading settings: $err')),
      ),
    );
  }
}
