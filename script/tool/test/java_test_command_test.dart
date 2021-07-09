// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/java_test_command.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'util.dart';

void main() {
  group('$JavaTestCommand', () {
    late FileSystem fileSystem;
    late MockPlatform mockPlatform;
    late Directory packagesDir;
    late CommandRunner<void> runner;
    late RecordingProcessRunner processRunner;

    setUp(() {
      fileSystem = MemoryFileSystem();
      mockPlatform = MockPlatform();
      packagesDir = createPackagesDirectory(fileSystem: fileSystem);
      processRunner = RecordingProcessRunner();
      final JavaTestCommand command = JavaTestCommand(
        packagesDir,
        processRunner: processRunner,
        platform: mockPlatform,
      );

      runner =
          CommandRunner<void>('java_test_test', 'Test for $JavaTestCommand');
      runner.addCommand(command);
    });

    test('Should run Java tests in Android implementation folder', () async {
      final Directory plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline
        },
        extraFiles: <String>[
          'example/android/gradlew',
          'android/src/test/example_test.java',
        ],
      );

      await runCapturingPrint(runner, <String>['java-test']);

      final Directory androidFolder =
          plugin.childDirectory('example').childDirectory('android');

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            androidFolder.childFile('gradlew').path,
            const <String>['testDebugUnitTest', '--info'],
            androidFolder.path,
          ),
        ]),
      );
    });

    test('Should run Java tests in example folder', () async {
      final Directory plugin = createFakePlugin(
        'plugin1',
        packagesDir,
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline
        },
        extraFiles: <String>[
          'example/android/gradlew',
          'example/android/app/src/test/example_test.java',
        ],
      );

      await runCapturingPrint(runner, <String>['java-test']);

      final Directory androidFolder =
          plugin.childDirectory('example').childDirectory('android');

      expect(
        processRunner.recordedCalls,
        orderedEquals(<ProcessCall>[
          ProcessCall(
            androidFolder.childFile('gradlew').path,
            const <String>['testDebugUnitTest', '--info'],
            androidFolder.path,
          ),
        ]),
      );
    });

    test('fails when the app needs to be built', () async {
      createFakePlugin(
        'plugin1',
        packagesDir,
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline
        },
        extraFiles: <String>[
          'example/android/app/src/test/example_test.java',
        ],
      );

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['java-test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('ERROR: Run "flutter build apk" on example'),
          contains('plugin1:\n'
              '    example has not been built.')
        ]),
      );
    });

    test('fails when a test fails', () async {
      final Directory pluginDir = createFakePlugin(
        'plugin1',
        packagesDir,
        platformSupport: <String, PlatformSupport>{
          kPlatformAndroid: PlatformSupport.inline
        },
        extraFiles: <String>[
          'example/android/gradlew',
          'example/android/app/src/test/example_test.java',
        ],
      );

      final String gradlewPath = pluginDir
          .childDirectory('example')
          .childDirectory('android')
          .childFile('gradlew')
          .path;
      processRunner.mockProcessesForExecutable[gradlewPath] = <io.Process>[
        MockProcess.failing()
      ];

      Error? commandError;
      final List<String> output = await runCapturingPrint(
          runner, <String>['java-test'], errorHandler: (Error e) {
        commandError = e;
      });

      expect(commandError, isA<ToolExit>());

      expect(
        output,
        containsAllInOrder(<Matcher>[
          contains('plugin1:\n'
              '    example tests failed.')
        ]),
      );
    });

    test('Skips when running no tests', () async {
      createFakePlugin(
        'plugin1',
        packagesDir,
      );

      final List<String> output =
          await runCapturingPrint(runner, <String>['java-test']);

      expect(
        output,
        containsAllInOrder(
            <Matcher>[contains('SKIPPING: No Java unit tests.')]),
      );
    });
  });
}
