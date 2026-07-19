import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/isar_provider.dart';
import 'backup_service.dart';

part 'backup_providers.g.dart';

@riverpod
BackupService backupService(BackupServiceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return BackupService(isar);
}
