import 'package:isar/isar.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/semester.dart';
import '../../domain/repositories/semester_repository.dart';
import '../../domain/validators/semester_validator.dart';
import '../models/semester_local.dart';

/// Canonical read-only active semester resolver used across all repositories
/// and services so `list.last` vs `findFirst()` conflicts cannot recur.
SemesterLocal? resolveActiveSemesterLocal(Isar isar) {
  if (!isar.isOpen) return null;

  final nonDeleted =
      isar.semesterLocals.where().isDeletedEqualTo(false).findAll();
  if (nonDeleted.isEmpty) return null;

  final explicitActive = nonDeleted
      .where(
        (s) => s.status == SemesterLocal.statusActive && s.isActive,
      )
      .toList();
  if (explicitActive.isNotEmpty) {
    return explicitActive.last;
  }

  // Compatibility fallback for unmigrated pre-BUG-017 rows opened directly
  // without startup migration.
  final legacyRows = nonDeleted
      .where((s) => !SemesterLocal.validStatuses.contains(s.status))
      .toList();
  if (legacyRows.isNotEmpty) {
    final flaggedActive = legacyRows.where((s) => s.isActive).toList();
    return flaggedActive.isNotEmpty ? flaggedActive.last : legacyRows.last;
  }

  return null;
}

/// Idempotently migrates legacy [SemesterLocal] records so every persisted
/// row has a valid lifecycle `status` (`draft` / `active` / `archived`),
/// synchronized `isActive` flag, and at most one active non-deleted semester.
Future<int> migrateLegacySemesters(Isar isar) async {
  if (!isar.isOpen) return 0;

  final existing = isar.semesterLocals.where().findAll();
  if (existing.isEmpty) return 0;

  var activeNonDeletedCount = 0;
  var needsMigration = false;
  for (final sem in existing) {
    final hasValidStatus = SemesterLocal.validStatuses.contains(sem.status);
    if (!hasValidStatus) {
      needsMigration = true;
      break;
    }
    if (sem.isDeleted) {
      if (sem.isActive || sem.status == SemesterLocal.statusActive) {
        needsMigration = true;
        break;
      }
      continue;
    }
    if (sem.isActive != (sem.status == SemesterLocal.statusActive)) {
      needsMigration = true;
      break;
    }
    if (sem.status == SemesterLocal.statusActive) {
      activeNonDeletedCount++;
      if (activeNonDeletedCount > 1) {
        needsMigration = true;
        break;
      }
    }
  }

  if (!needsMigration) return 0;

  return isar.writeAsync<int>(normalizeSemestersInWriteTx);
}

SemesterStatus _resolveEntityStatus(
  SemesterLocal cached,
  SemesterLocal? activeLocal,
) {
  final parsed = SemesterStatus.tryParse(cached.status);
  if (parsed == SemesterStatus.active) {
    return (activeLocal != null && activeLocal.id == cached.id)
        ? SemesterStatus.active
        : SemesterStatus.archived;
  }
  if (parsed != null) {
    return parsed;
  }
  return (activeLocal != null && activeLocal.id == cached.id)
      ? SemesterStatus.active
      : SemesterStatus.archived;
}

Semester _mapSemesterToEntity(
  SemesterLocal cached, {
  SemesterStatus? statusOverride,
}) {
  final status = statusOverride ??
      SemesterStatus.tryParse(cached.status) ??
      (cached.isActive ? SemesterStatus.active : SemesterStatus.archived);
  return Semester(
    id: cached.serverId ?? cached.id.toString(),
    localId: cached.id,
    name: cached.name,
    startDate: cached.startDate,
    endDate: cached.endDate,
    requiredAttendanceRate: cached.requiredAttendanceRate,
    status: status,
  );
}

List<Semester> _readNonDeletedSemestersInTx(Isar isar) {
  final list = isar.semesterLocals.where().isDeletedEqualTo(false).findAll();
  return list.map((s) => _mapSemesterToEntity(s)).toList();
}

void _demoteOtherActiveSemestersInTx(
  Isar isar, {
  required int exceptId,
  required DateTime now,
}) {
  final activeRows = isar.semesterLocals
      .where()
      .isDeletedEqualTo(false)
      .findAll()
      .where(
        (s) =>
            s.id != exceptId &&
            (s.isActive || s.status == SemesterLocal.statusActive),
      )
      .toList();

  for (final other in activeRows) {
    other
      ..isActive = false
      ..status = SemesterLocal.statusArchived
      ..updatedAt = now;
  }
  if (activeRows.isNotEmpty) {
    isar.semesterLocals.putAll(activeRows);
  }
}

int normalizeSemestersInWriteTx(Isar isar) {
  final all = isar.semesterLocals.where().findAll();
  if (all.isEmpty) return 0;

  final now = DateTime.now().toUtc();
  final nonDeleted = <SemesterLocal>[];
  final explicitActive = <SemesterLocal>[];
  final legacyRows = <SemesterLocal>[];
  final changedIds = <int>{};
  final updatedRows = <SemesterLocal>[];

  for (final sem in all) {
    if (sem.isDeleted) {
      final needsFix = sem.isActive ||
          !SemesterLocal.validStatuses.contains(sem.status) ||
          sem.status == SemesterLocal.statusActive;
      if (needsFix) {
        sem
          ..isActive = false
          ..status = SemesterLocal.statusArchived
          ..updatedAt = now;
        changedIds.add(sem.id);
        updatedRows.add(sem);
      }
      continue;
    }

    nonDeleted.add(sem);
    if (!SemesterLocal.validStatuses.contains(sem.status)) {
      legacyRows.add(sem);
    } else if (sem.status == SemesterLocal.statusActive) {
      explicitActive.add(sem);
    }
  }

  final SemesterLocal? targetActive;
  if (explicitActive.isNotEmpty) {
    targetActive = explicitActive.last;
  } else if (legacyRows.isNotEmpty) {
    final flaggedActive = legacyRows.where((s) => s.isActive).toList();
    targetActive =
        flaggedActive.isNotEmpty ? flaggedActive.last : legacyRows.last;
  } else {
    targetActive = null;
  }

  for (final sem in nonDeleted) {
    final String expectedStatus;
    final bool expectedActive;

    if (identical(sem, targetActive)) {
      expectedStatus = SemesterLocal.statusActive;
      expectedActive = true;
    } else if (sem.status == SemesterLocal.statusDraft) {
      expectedStatus = SemesterLocal.statusDraft;
      expectedActive = false;
    } else {
      expectedStatus = SemesterLocal.statusArchived;
      expectedActive = false;
    }

    if (sem.status != expectedStatus || sem.isActive != expectedActive) {
      sem
        ..status = expectedStatus
        ..isActive = expectedActive
        ..updatedAt = now;
      if (changedIds.add(sem.id)) {
        updatedRows.add(sem);
      }
    }
  }

  if (updatedRows.isNotEmpty) {
    isar.semesterLocals.putAll(updatedRows);
  }
  return updatedRows.length;
}

class SemesterRepositoryImpl implements SemesterRepository {
  final Isar _isar;

  SemesterRepositoryImpl(this._isar);

  @override
  Future<void> createSemester(Semester semester) async {
    SemesterValidator.validateBasic(semester);

    final trimmedName = semester.name.trim();
    final startLocal =
        SemesterValidator.toLocalCalendarDate(semester.startDate);
    final endLocal = SemesterValidator.toLocalCalendarDate(semester.endDate);
    final normalizedCandidate = semester.copyWith(
      name: trimmedName,
      startDate: startLocal,
      endDate: endLocal,
    );

    final initialServerId =
        (semester.id != null && semester.id!.trim().isNotEmpty)
            ? semester.id!.trim()
            : generateUuid();
    final now = DateTime.now().toUtc();

    await _isar.writeAsync((isar) {
      normalizeSemestersInWriteTx(isar);

      final existing = _readNonDeletedSemestersInTx(isar);
      SemesterValidator.validateForSave(
        candidate: normalizedCandidate,
        existingSemesters: existing,
      );

      var serverId = initialServerId;
      while (
          isar.semesterLocals.where().serverIdEqualTo(serverId).findFirst() !=
              null) {
        serverId = generateUuid();
      }

      final newId = isar.semesterLocals.autoIncrement();
      if (normalizedCandidate.status == SemesterStatus.active) {
        _demoteOtherActiveSemestersInTx(isar, exceptId: newId, now: now);
      }

      final localSemester = SemesterLocal()
        ..id = newId
        ..serverId = serverId
        ..name = trimmedName
        ..startDate = startLocal
        ..endDate = endLocal
        ..requiredAttendanceRate = normalizedCandidate.requiredAttendanceRate
        ..status = normalizedCandidate.status.toShortString()
        ..isActive = normalizedCandidate.isActive
        ..createdAt = now
        ..updatedAt = now
        ..isDirty = false
        ..isDeleted = false;

      isar.semesterLocals.put(localSemester);
    });
  }

  @override
  Future<void> updateSemester(Semester semester) async {
    final localId = semester.localId;
    if (localId == null || localId <= 0) {
      throw const ValidationException(
        'Cannot update semester without a valid local ID.',
        'SEMESTER_MISSING_ID',
      );
    }

    final trimmedName = semester.name.trim();
    final startLocal =
        SemesterValidator.toLocalCalendarDate(semester.startDate);
    final endLocal = SemesterValidator.toLocalCalendarDate(semester.endDate);
    final normalizedCandidate = semester.copyWith(
      name: trimmedName,
      startDate: startLocal,
      endDate: endLocal,
    );
    SemesterValidator.validateBasic(normalizedCandidate);

    final now = DateTime.now().toUtc();

    await _isar.writeAsync((isar) {
      normalizeSemestersInWriteTx(isar);

      final existingLocal = isar.semesterLocals.get(localId);
      if (existingLocal == null || existingLocal.isDeleted) {
        throw const ValidationException(
          'Semester not found.',
          'SEMESTER_NOT_FOUND',
        );
      }

      if (existingLocal.status == SemesterLocal.statusArchived) {
        throw const ValidationException(
          'Archived semesters are read-only. Activate the semester first to edit it.',
          'SEMESTER_ARCHIVED_READ_ONLY',
        );
      }

      final existingAll = _readNonDeletedSemestersInTx(isar);
      SemesterValidator.validateForSave(
        candidate: normalizedCandidate,
        existingSemesters: existingAll,
      );

      if (normalizedCandidate.status == SemesterStatus.active) {
        _demoteOtherActiveSemestersInTx(isar, exceptId: localId, now: now);
      }

      existingLocal
        ..name = trimmedName
        ..startDate = startLocal
        ..endDate = endLocal
        ..requiredAttendanceRate = normalizedCandidate.requiredAttendanceRate
        ..status = normalizedCandidate.status.toShortString()
        ..isActive = normalizedCandidate.isActive
        ..updatedAt = now
        ..isDirty = false;

      isar.semesterLocals.put(existingLocal);
    });
  }

  @override
  Future<void> setActiveSemester(int localId) async {
    final now = DateTime.now().toUtc();
    await _isar.writeAsync((isar) {
      normalizeSemestersInWriteTx(isar);

      final target = isar.semesterLocals.get(localId);
      if (target == null || target.isDeleted) {
        throw const ValidationException(
          'Semester not found.',
          'SEMESTER_NOT_FOUND',
        );
      }

      _demoteOtherActiveSemestersInTx(isar, exceptId: localId, now: now);

      target
        ..status = SemesterLocal.statusActive
        ..isActive = true
        ..updatedAt = now
        ..isDirty = false;
      isar.semesterLocals.put(target);
    });
  }

  @override
  Future<void> archiveSemester(int localId) async {
    final now = DateTime.now().toUtc();
    await _isar.writeAsync((isar) {
      normalizeSemestersInWriteTx(isar);

      final target = isar.semesterLocals.get(localId);
      if (target == null || target.isDeleted) {
        throw const ValidationException(
          'Semester not found.',
          'SEMESTER_NOT_FOUND',
        );
      }

      if (target.status == SemesterLocal.statusArchived && !target.isActive) {
        return;
      }

      target
        ..status = SemesterLocal.statusArchived
        ..isActive = false
        ..updatedAt = now
        ..isDirty = false;
      isar.semesterLocals.put(target);
    });
  }

  @override
  Future<Semester?> getSemesterById(int localId) async {
    final cached = _isar.semesterLocals.get(localId);
    if (cached == null || cached.isDeleted) return null;
    final activeLocal = resolveActiveSemesterLocal(_isar);
    return _mapSemesterToEntity(
      cached,
      statusOverride: _resolveEntityStatus(cached, activeLocal),
    );
  }

  @override
  Future<Semester?> getActiveSemester() async {
    final activeLocal = resolveActiveSemesterLocal(_isar);
    if (activeLocal == null) return null;
    return _mapSemesterToEntity(
      activeLocal,
      statusOverride: SemesterStatus.active,
    );
  }

  @override
  Future<bool> hasActiveSemester() async {
    return resolveActiveSemesterLocal(_isar) != null;
  }

  @override
  Future<List<Semester>> getAllSemesters() async {
    final list = _isar.semesterLocals.where().isDeletedEqualTo(false).findAll();
    final activeLocal = resolveActiveSemesterLocal(_isar);

    final mapped = list
        .map(
          (cached) => _mapSemesterToEntity(
            cached,
            statusOverride: _resolveEntityStatus(cached, activeLocal),
          ),
        )
        .toList();

    mapped.sort((a, b) {
      final dateCmp = SemesterValidator.normalizeDate(b.startDate).compareTo(
        SemesterValidator.normalizeDate(a.startDate),
      );
      if (dateCmp != 0) return dateCmp;
      return (b.localId ?? 0).compareTo(a.localId ?? 0);
    });

    return mapped;
  }
}
