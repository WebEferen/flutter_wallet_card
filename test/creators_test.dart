import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/creators.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';

void main() {
  final fixtures = Directory('test/fixtures');
  final outputDirectory = Directory('${fixtures.path}/temp_test');
  final creators = Creators(directory: outputDirectory);

  group('Creators', () {
    setUp(() {
      outputDirectory.createSync(recursive: true);
    });

    test('should create pass file', () async {
      final passFile = await creators.createPass(PasskitPass(
        formatVersion: 1,
        passTypeIdentifier: 'some-identifier',
        description: 'some-description',
        teamIdentifier: 'some-team-identifier',
        organizationName: 'some-organization-name',
        serialNumber: 'some-serial-number',
      ));

      expect(passFile.existsSync(), true);
      passFile.deleteSync();
    });

    test('should create manifest file', () async {
      final manifestFile = await creators.createManifest({
        'pass.json': Uint8List(0),
      });

      expect(manifestFile.existsSync(), true);
      manifestFile.deleteSync();
    });

    tearDown(() {
      outputDirectory.deleteSync(recursive: true);
    });
  });
}
