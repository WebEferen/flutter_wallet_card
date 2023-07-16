import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/passkit.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');

  final id = 'example_passkit';
  final encoder = ZipFileEncoder();
  final outputDirectory = Directory('test/fixtures/test_pass');
  final exampleDirectory = Directory('test/fixtures/example_passkit');

  group('Passkit', () {
    group('saveFromPath', () {
      test('should throw if given file doesnt exists', () {
        final passkit = Passkit(directoryName: outputDirectory.path);
        final file = File('not-existing-file.passkit');

        expect(passkit.saveFromPath(id: id, file: file), throwsException);
      });

      test('should throw if passkit exists', () {
        final passkit = Passkit(directoryName: outputDirectory.path);

        final directory = Directory('test/fixtures/test_pass')..createSync();
        final file = File('${directory.path}/example.passkit')..createSync();

        expect(passkit.saveFromPath(id: id, file: file), throwsException);
        directory.deleteSync(recursive: true);
      });

      testWidgets('should parse passkit', (tester) async {
        final messenger = tester.binding.defaultBinaryMessenger;

        messenger.setMockMethodCallHandler(pathProviderChannel, (c) async {
          if (c.method == 'getApplicationDocumentsDirectory') return '.';
          return null;
        });

        final zipFile = File('${exampleDirectory.path}.zip');
        encoder.zipDirectory(exampleDirectory, filename: zipFile.path);

        final passkit = Passkit(directoryName: outputDirectory.path);
        final passkitFile = await passkit.saveFromPath(id: id, file: zipFile);

        final file = File('${outputDirectory.path}/example_passkit/pass.json');
        expect(file.existsSync(), true);
        expect(passkitFile.json.serialNumber, '0000001');

        zipFile.deleteSync(recursive: true);
        outputDirectory.deleteSync(recursive: true);
      });
    });

    group('generate', () {
      testWidgets('should generate passkit', (tester) async {
        final messenger = tester.binding.defaultBinaryMessenger;

        messenger.setMockMethodCallHandler(pathProviderChannel, (c) async {
          if (c.method == 'getApplicationDocumentsDirectory') return '.';
          return null;
        });

        final passesDirectory = Directory('passes');
        final passkit = Passkit(directoryName: outputDirectory.path);
        final pass = File('${exampleDirectory.path}/pass.json');
        final pkpass = File('${outputDirectory.path}/testowo.pkpass');

        final generated = await passkit.generate(
          id: 'testowo',
          pkpass: pkpass,
          directory: outputDirectory,
          passkitPass: PasskitPass.fromJson(
            jsonDecode(pass.readAsStringSync()),
          ),
        );

        expect(generated.passFile.existsSync(), true);
        expect(generated.passkitFile.file.existsSync(), true);
        expect(passesDirectory.existsSync(), true);
      });
    });
  });
}
