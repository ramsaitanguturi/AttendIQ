import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';

part 'isar_provider.g.dart';

@riverpod
Future<Isar> isar(IsarRef ref) async {
  // In later phases, we will use path_provider to resolve the directory on mobile devices.
  // For the Phase 0 bootstrap, we open Isar with an empty schema list.
  return Isar.open(
    schemas: const [], // Register schemas (Semester, Subject, etc.) here in Phase 1+
    name: AppConstants.isarDbName,
    directory: '.',
  );
}
