import 'dart:io';

import 'package:attend_iq/core/backup/backup_path_helper.dart';
import 'package:attend_iq/core/widgets/export_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel storageChannel = MethodChannel(
    'com.ramsa.attendiq/storage',
  );

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  group('Android Open File Chooser UX — Native Invariants', () {
    test(
      'AndroidManifest.xml declares ACTION_VIEW query without weakening storage security',
      () {
        final manifest =
            File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

        expect(manifest, contains('<queries>'));
        expect(manifest, contains('android.intent.action.VIEW'));
        expect(manifest, contains('android:scheme="content"'));
        expect(manifest, contains('android:mimeType="*/*"'));

        expect(manifest, isNot(contains('MANAGE_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('READ_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('requestLegacyExternalStorage')));
        expect(manifest, isNot(contains('androidx.core.content.FileProvider')));
      },
    );

    test(
      'MainActivity.kt checks compatible viewers before createChooser and handles launch errors safely',
      () {
        final kt = File(
          'android/app/src/main/kotlin/com/ramsa/attendiq/attend_iq/MainActivity.kt',
        ).readAsStringSync();

        expect(kt, contains('hasCompatibleViewer(viewIntent)'));
        expect(kt, contains('queryIntentActivities'));
        expect(kt, contains('resolveActivity(packageManager)'));
        expect(kt, contains('NO_COMPATIBLE_APP'));
        expect(kt, contains('ACTIVITY_LAUNCH_FAILED'));
        expect(kt, contains('INVALID_URI'));
        expect(kt, contains('INVALID_ARGS'));
        expect(kt, contains('FLAG_GRANT_READ_URI_PERMISSION'));
        expect(kt, isNot(contains('FLAG_GRANT_WRITE_URI_PERMISSION')));
        expect(kt, isNot(contains('FileProvider')));
      },
    );
  });

  group('BackupPathHelper.openExportUriWithResult', () {
    test(
      'returns success for structured map and legacy bool responses',
      () async {
        final List<MethodCall> calls = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          calls.add(call);
          if (calls.length == 1) {
            return <String, dynamic>{
              'opened': true,
              'mimeType': 'application/pdf',
            };
          }
          return true;
        });

        final structured = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://media/external/file/42',
          mimeType: 'application/pdf',
          isAndroidOverride: true,
        );
        expect(structured.opened, isTrue);
        expect(structured.reason, OpenExportFailureReason.none);
        expect(structured.errorCode, isNull);

        final legacyBool = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://media/external/file/43',
          mimeType: 'text/csv',
          isAndroidOverride: true,
        );
        expect(legacyBool.opened, isTrue);
        expect(legacyBool.reason, OpenExportFailureReason.none);
        expect(calls, hasLength(2));
        expect(calls.first.arguments, <String, dynamic>{
          'contentUri': 'content://media/external/file/42',
          'mimeType': 'application/pdf',
        });
      },
    );

    test(
      'returns structured noCompatibleApp failure when no viewer is installed',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          return <String, dynamic>{
            'opened': false,
            'errorCode': 'NO_COMPATIBLE_APP',
            'message': 'No compatible application is installed.',
            'mimeType': 'application/octet-stream',
          };
        });

        final result = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://media/external/file/101',
          mimeType: 'application/octet-stream',
          isAndroidOverride: true,
        );

        expect(result.opened, isFalse);
        expect(result.reason, OpenExportFailureReason.noCompatibleApp);
        expect(result.errorCode, 'NO_COMPATIBLE_APP');
        expect(result.message, 'No compatible application is installed.');
      },
    );

    test(
      'handles activity launch failure PlatformException without throwing',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          throw PlatformException(
            code: 'ACTIVITY_LAUNCH_FAILED',
            message: 'SecurityException while starting chooser',
          );
        });

        final result = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://media/external/file/202',
          mimeType: 'application/pdf',
          isAndroidOverride: true,
        );

        expect(result.opened, isFalse);
        expect(result.reason, OpenExportFailureReason.activityLaunchFailed);
        expect(result.errorCode, 'ACTIVITY_LAUNCH_FAILED');
        expect(result.message, 'SecurityException while starting chooser');
      },
    );

    test(
      'rejects invalid or missing URIs before invoking channel and maps native INVALID_URI',
      () async {
        var channelInvoked = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          channelInvoked = true;
          throw PlatformException(
            code: 'INVALID_URI',
            message: 'Only external content:// export URIs can be opened.',
          );
        });

        const invalidInputs = <String>[
          '',
          '   ',
          '/storage/emulated/0/Documents/Report.pdf',
          'file:///data/user/0/app/backup.attendiq',
          'content://',
          'content:///missing-authority',
        ];

        for (final uri in invalidInputs) {
          final result = await BackupPathHelper.openExportUriWithResult(
            contentUri: uri,
            mimeType: 'application/pdf',
            isAndroidOverride: true,
          );
          expect(result.opened, isFalse, reason: 'URI "$uri" should fail');
          expect(
            result.reason,
            OpenExportFailureReason.invalidUri,
            reason: 'URI "$uri" should map to invalidUri',
          );
        }
        expect(channelInvoked, isFalse);

        // Native INVALID_URI / INVALID_ARGS PlatformException mapping.
        final nativeRejected = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://com.ramsa.attendiq.attend_iq.share/file.pdf',
          mimeType: 'application/pdf',
          isAndroidOverride: true,
        );
        expect(channelInvoked, isTrue);
        expect(nativeRejected.opened, isFalse);
        expect(nativeRejected.reason, OpenExportFailureReason.invalidUri);
        expect(nativeRejected.errorCode, 'INVALID_URI');
      },
    );

    test(
      'handles MissingPluginException, unexpected response types, and non-Android platforms',
      () async {
        final nonAndroid = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://media/external/file/55',
          mimeType: 'application/pdf',
          isAndroidOverride: false,
        );
        expect(nonAndroid.opened, isFalse);
        expect(nonAndroid.reason, OpenExportFailureReason.unsupportedPlatform);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          throw MissingPluginException('No implementation found');
        });
        final missingPlugin = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://media/external/file/55',
          mimeType: 'application/pdf',
          isAndroidOverride: true,
        );
        expect(missingPlugin.opened, isFalse);
        expect(missingPlugin.reason, OpenExportFailureReason.channelError);
        expect(missingPlugin.errorCode, 'CHANNEL_ERROR');

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async => null);
        final nullResponse = await BackupPathHelper.openExportUriWithResult(
          contentUri: 'content://media/external/file/55',
          mimeType: 'application/pdf',
          isAndroidOverride: true,
        );
        expect(nullResponse.opened, isFalse);
        expect(nullResponse.reason, OpenExportFailureReason.channelError);
        expect(nullResponse.errorCode, 'EMPTY_RESPONSE');
      },
    );
  });

  group('ExportSuccessDialog Open File Fallback UX', () {
    testWidgets(
      'successful openExportUri launches without displaying fallback SnackBar',
      (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          return <String, dynamic>{'opened': true};
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ExportSuccessDialog(
                title: 'PDF Report exported successfully',
                exportResult: ExportSaveResult(
                  contentUri: 'content://media/external/file/701',
                  displayPath:
                      'Internal Storage/Documents/AttendIQ/Reports/Report.pdf',
                  fileName: 'Report.pdf',
                  subFolder: 'Reports',
                ),
                mimeType: 'application/pdf',
                isAndroidOverride: true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open File'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'no compatible viewer displays clear actionable SnackBar with Share action',
      (tester) async {
        final tempRoot = Directory.systemTemp.createTempSync('open_ux_noview_');
        try {
          final staged = File(
            '${tempRoot.path}${Platform.pathSeparator}Backup.attendiq',
          )..writeAsStringSync('{}');

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            return <String, dynamic>{
              'opened': false,
              'errorCode': 'NO_COMPATIBLE_APP',
              'message': 'No compatible application is installed.',
            };
          });

          List<XFile>? sharedFromSnackBar;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ExportSuccessDialog(
                  title: 'Backup exported successfully',
                  exportResult: ExportSaveResult(
                    contentUri: 'content://media/external/file/702',
                    shareableFilePath: staged.path,
                    displayPath:
                        'Internal Storage/Documents/AttendIQ/Backups/Backup.attendiq',
                    fileName: 'Backup.attendiq',
                    subFolder: 'Backups',
                  ),
                  mimeType: 'application/octet-stream',
                  isAndroidOverride: true,
                  shareFilesOverride: (files, {text, subject}) async {
                    sharedFromSnackBar = files;
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open File'));
          await tester.pumpAndSettle();

          expect(
            find.textContaining(
              'No compatible app found to open Backup.attendiq',
            ),
            findsOneWidget,
          );
          expect(
            find.textContaining('Use Share or open via Files app.'),
            findsOneWidget,
          );
          expect(find.widgetWithText(SnackBarAction, 'Share'), findsOneWidget);

          await tester.tap(find.widgetWithText(SnackBarAction, 'Share'));
          for (var i = 0; i < 10 && sharedFromSnackBar == null; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          expect(sharedFromSnackBar, isNotNull);
          expect(sharedFromSnackBar!.single.path, staged.path);
        } finally {
          if (tempRoot.existsSync()) {
            tempRoot.deleteSync(recursive: true);
          }
        }
      },
    );

    testWidgets(
      'activity launch failure and invalid URI surface error SnackBar without crashing',
      (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          throw PlatformException(
            code: 'ACTIVITY_LAUNCH_FAILED',
            message: 'Unable to start activity',
          );
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ExportSuccessDialog(
                title: 'CSV Report exported successfully',
                exportResult: ExportSaveResult(
                  contentUri: 'content://media/external/file/703',
                  displayPath:
                      'Internal Storage/Documents/AttendIQ/Reports/Report.csv',
                  fileName: 'Report.csv',
                  subFolder: 'Reports',
                ),
                mimeType: 'text/csv',
                isAndroidOverride: true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open File'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Unable to open Report.csv directly.'),
          findsOneWidget,
        );
        expect(find.textContaining('Open Files app to view.'), findsOneWidget);
        expect(find.widgetWithText(SnackBarAction, 'Share'), findsNothing);
      },
    );

    testWidgets(
      'invalid URI in ExportSaveResult displays fallback SnackBar without channel call',
      (tester) async {
        var channelCalled = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          channelCalled = true;
          return <String, dynamic>{'opened': true};
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ExportSuccessDialog(
                title: 'JSON Data exported successfully',
                exportResult: ExportSaveResult(
                  contentUri: 'content://',
                  displayPath: 'Internal Storage/Documents/AttendIQ/Data.json',
                  fileName: 'Data.json',
                  subFolder: '',
                ),
                mimeType: 'application/json',
                isAndroidOverride: true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open File'));
        await tester.pumpAndSettle();

        expect(channelCalled, isFalse);
        expect(
          find.textContaining('Unable to open Data.json directly.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ExportSuccessDialog.show dismisses modal barrier on failure so SnackBar Share action is interactive',
      (tester) async {
        final tempRoot = Directory.systemTemp.createTempSync('open_ux_modal_');
        try {
          final staged = File(
            '${tempRoot.path}${Platform.pathSeparator}Report.csv',
          )..writeAsStringSync('Subject,Pct\nCS,100%\n');

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            return <String, dynamic>{
              'opened': false,
              'errorCode': 'NO_COMPATIBLE_APP',
              'message': 'No compatible application is installed.',
            };
          });

          List<XFile>? sharedFiles;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        ExportSuccessDialog.show(
                          context: context,
                          title: 'CSV Report exported successfully',
                          exportResult: ExportSaveResult(
                            contentUri: 'content://media/external/file/704',
                            shareableFilePath: staged.path,
                            displayPath:
                                'Internal Storage/Documents/AttendIQ/Reports/Report.csv',
                            fileName: 'Report.csv',
                            subFolder: 'Reports',
                          ),
                          mimeType: 'text/csv',
                          isAndroidOverride: true,
                          shareFilesOverride: (files, {text, subject}) async {
                            sharedFiles = files;
                          },
                        );
                      },
                      child: const Text('Show Export Dialog'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Show Export Dialog'));
          await tester.pumpAndSettle();
          expect(find.text('Open File'), findsOneWidget);

          await tester.tap(find.text('Open File'));
          await tester.pumpAndSettle();

          // Modal dialog popped; SnackBar is visible and unobstructed.
          expect(find.text('Open File'), findsNothing);
          expect(
            find.textContaining('No compatible app found to open Report.csv'),
            findsOneWidget,
          );
          await tester.tap(find.widgetWithText(SnackBarAction, 'Share'));
          for (var i = 0; i < 10 && sharedFiles == null; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          expect(sharedFiles, isNotNull);
          expect(sharedFiles!.single.path, staged.path);
        } finally {
          if (tempRoot.existsSync()) {
            tempRoot.deleteSync(recursive: true);
          }
        }
      },
    );
  });
}
