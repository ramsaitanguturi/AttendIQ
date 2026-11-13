import 'dart:convert';
import 'dart:io';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:isar/isar.dart';

int _testDbSequence = 0;
bool _isarInitialized = false;

Future<String?> resolveIsarNativeLibraryPath() async {
  final packageConfigFile = File('.dart_tool/package_config.json');
  if (!packageConfigFile.existsSync()) return null;

  final decoded = jsonDecode(await packageConfigFile.readAsString())
      as Map<String, dynamic>;
  final packages = decoded['packages'] as List<dynamic>? ?? const [];
  Map<String, dynamic>? isarPackage;
  for (final pkg in packages) {
    if (pkg is Map<String, dynamic> && pkg['name'] == 'isar_flutter_libs') {
      isarPackage = pkg;
      break;
    }
  }
  if (isarPackage == null) return null;

  final rawRootUri = isarPackage['rootUri'] as String?;
  if (rawRootUri == null || rawRootUri.isEmpty) return null;

  final rootDir = Directory.fromUri(packageConfigFile.uri.resolve(rawRootUri));
  final String relativePath;
  if (Platform.isWindows) {
    relativePath = 'windows${Platform.pathSeparator}isar.dll';
  } else if (Platform.isLinux) {
    relativePath = 'linux${Platform.pathSeparator}libisar.so';
  } else if (Platform.isMacOS) {
    relativePath = 'macos${Platform.pathSeparator}libisar.dylib';
  } else {
    return null;
  }

  final file = File('${rootDir.path}${Platform.pathSeparator}$relativePath');
  return file.existsSync() ? file.path : null;
}

Future<void> ensureIsarInitialized() async {
  if (_isarInitialized) return;
  final nativeLibPath = await resolveIsarNativeLibraryPath();
  if (nativeLibPath != null) {
    await Isar.initialize(nativeLibPath);
  }
  _isarInitialized = true;
}

class TestIsarInstance {
  final Isar isar;
  final Directory tempDir;

  const TestIsarInstance({
    required this.isar,
    required this.tempDir,
  });

  Future<void> dispose() async {
    if (isar.isOpen) {
      isar.close();
    }
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {
        // Suppress Windows filesystem delete race
      }
    }
  }
}

TestIsarInstance openTestIsar({
  String prefix = 'test_isar',
  List<IsarGeneratedSchema>? schemas,
}) {
  final tempDir = Directory.systemTemp.createTempSync('attendiq_${prefix}_');
  final name =
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_testDbSequence++}';
  final isar = Isar.open(
    schemas: schemas ?? appIsarSchemas,
    name: name,
    directory: tempDir.path,
    inspector: false,
  );
  return TestIsarInstance(isar: isar, tempDir: tempDir);
}

