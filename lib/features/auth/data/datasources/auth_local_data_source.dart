import 'package:isar/isar.dart';
import '../models/user_local.dart';
import '../models/semester_local.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserLocal user);
  Future<UserLocal?> getUser();
  Future<void> clearUser();

  Future<void> saveSemester(SemesterLocal semester);
  Future<SemesterLocal?> getActiveSemester();
  Future<bool> hasActiveSemester();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Isar _isar;

  AuthLocalDataSourceImpl(this._isar);

  @override
  Future<void> saveUser(UserLocal user) async {
    await _isar.writeAsync((isar) {
      isar.userLocals.clear();
      if (user.id == 0) {
        user.id = isar.userLocals.autoIncrement();
      }
      isar.userLocals.put(user);
    });
  }

  @override
  Future<UserLocal?> getUser() async {
    return _isar.userLocals.where().findFirst();
  }

  @override
  Future<void> clearUser() async {
    await _isar.writeAsync((isar) {
      isar.userLocals.clear();
      isar.semesterLocals.clear();
    });
  }

  @override
  Future<void> saveSemester(SemesterLocal semester) async {
    await _isar.writeAsync((isar) {
      if (semester.id == 0) {
        semester.id = isar.semesterLocals.autoIncrement();
      }
      isar.semesterLocals.put(semester);
    });
  }

  @override
  Future<SemesterLocal?> getActiveSemester() async {
    return _isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
  }

  @override
  Future<bool> hasActiveSemester() async {
    final active = await getActiveSemester();
    return active != null;
  }
}

