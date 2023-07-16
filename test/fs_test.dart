import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/fs.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');

  final Fs fs = Fs();
  final encoder = ZipFileEncoder();

  final fixtures = Directory('test/fixtures');
  final passkitFixtures = Directory('${fixtures.path}/example_passkit');
  final zip = File('${fixtures.path}/passkit.zip');

  group('Fs', () {
    group('Unpack', () {
      test('should throw when passkit not found', () async {
        expect(
          fs.unpack(path: 'some-path'),
          throwsException,
          reason: 'Missing passkit file',
        );
      });

      test('should throw on corrupted zip file', () async {
        zip.createSync(recursive: true);
        expect(fs.unpack(path: zip.path), throwsException);
      });

      test('should unpack zip file', () async {
        encoder.zipDirectory(passkitFixtures, filename: zip.path);
        fs.unpack(path: zip.path);

        final unpacked = Directory('${fixtures.path}/passkit');
        expect(unpacked.existsSync(), true);

        unpacked.delete(recursive: true);
        zip.delete();
      });
    });

    group('Create directory', () {
      testWidgets('should create directory', (tester) async {
        final messenger = tester.binding.defaultBinaryMessenger;

        messenger.setMockMethodCallHandler(pathProviderChannel, (c) async {
          if (c.method == 'getApplicationDocumentsDirectory') return '.';
          return null;
        });

        final directory = await getApplicationDocumentsDirectory();
        fs.createDirectory(name: 'test');

        expect(directory.existsSync(), true);
        directory.delete();
      });
    });

    group('Delete', () {
      test('should delete files', () {
        final directory = Directory('${fixtures.path}/test')..createSync();
        final file = File('${directory.path}/file.txt')..createSync();

        expect(file.existsSync(), true);
        expect(directory.existsSync(), true);

        fs.delete(directory, file);

        expect(file.existsSync(), false);
        expect(directory.existsSync(), false);
      });
    });
  });
}
