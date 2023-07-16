import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/parser.dart';

void main() {
  final fixtures = Directory('test/fixtures');
  final passkitFixtures = Directory('${fixtures.path}/example_passkit');
  final passJson = File('${passkitFixtures.path}/pass.json');
  final pkpass = File('${fixtures.path}/example.pkpass');

  group('Parser', () {
    test('should initialize with valid data', () async {
      final parser = Parser(
        id: 'example_passkit',
        directory: passkitFixtures,
        passFile: passJson,
        file: pkpass,
      );

      final passkit = await parser.parse();

      expect(passkit.id, 'example_passkit');
      expect(passkit.json.description, 'Some description');
      expect(passkit.json.serialNumber, '0000001');
      expect(passkit.json.formatVersion, 1);
    });

    test('should throw on invalid data', () async {
      final parser = Parser(
        id: 'example_passkit',
        directory: passkitFixtures,
        passFile: File('not-existing-pass.json'),
        file: File('not-existing-pass-file.pkpass'),
      );

      expect(parser.parse(), throwsException);
    });
  });
}
