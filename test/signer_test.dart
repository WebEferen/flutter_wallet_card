import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/signer.dart';

void main() {
  final fixtures = Directory('test/fixtures');
  final certificates = Directory('${fixtures.path}/certificates');

  final certP12 = File('${certificates.path}/cert.p12');
  final wwdrPem = File('${certificates.path}/wwdr.pem');
  final signature = File('${certificates.path}/signature');

  group('Signer', () {
    group('isOpenSSLSupported', () {
      test('should return true when supported', () async {
        final isSupported = await Signer.isOpenSSLSupported();
        expect(isSupported, true);
      });
    });

    group('instantiate class', () {
      test('should throw when cert does not exists', () {
        final File certP12 = File('${certificates.path}/missing.p12');
        final File wwdrPem = File('${certificates.path}/wwdr.pem');

        expect(
          () => Signer(wwdrPem: wwdrPem, certificateP12: certP12),
          throwsException,
        );
      });

      test('should throw when wwdr does not exists', () {
        final File certP12 = File('${certificates.path}/cert.p12');
        final File wwdrPem = File('${certificates.path}/missing.pem');

        expect(
          () => Signer(wwdrPem: wwdrPem, certificateP12: certP12),
          throwsException,
        );
      });

      test('should create class', () {
        final signer = Signer(wwdrPem: wwdrPem, certificateP12: certP12);

        expect(signer.certificateP12.path, certP12.path);
        expect(signer.wwdrPem.path, wwdrPem.path);
      });
    });

    group('getSignature', () {
      test('should throw when no signature generated', () {
        final signer = Signer(wwdrPem: wwdrPem, certificateP12: certP12);
        expect(() => signer.getSignature(), throwsException);
      });

      test('should return generated signature', () {
        Signer.directory = certificates;
        final signer = Signer(wwdrPem: wwdrPem, certificateP12: certP12);

        signature..createSync(recursive: true);
        expect(signer.getSignature(), []);

        signature.deleteSync(recursive: true);
      });
    });

    group('generators', () {
      test('should generate certificate', () async {
        Signer.directory = certificates;
        final signer = Signer(wwdrPem: wwdrPem, certificateP12: certP12);

        await signer.generateCertificate();
        expect(signer.certPem.existsSync(), true);

        signer.certPem.deleteSync(recursive: true);
      });

      test('should generate key', () async {
        Signer.directory = certificates;
        final signer = Signer(wwdrPem: wwdrPem, certificateP12: certP12);

        await signer.generateKey();
        expect(signer.keyPem.existsSync(), true);

        signer.keyPem.deleteSync(recursive: true);
      });
    });

    group('generateSignature', () {
      test('should throw when cert.pem is missing', () async {
        Signer.directory = certificates;
        final signer = Signer(wwdrPem: wwdrPem, certificateP12: certP12);

        final manifest = File('${certificates.path}/manifest')
          ..createSync(recursive: true)
          ..writeAsStringSync('{}');

        expect(signer.generateSignature(manifest: manifest), throwsException);
        expect(signer.signature.existsSync(), false);
        manifest.deleteSync(recursive: true);
      });

      test('should generate signature', () async {
        Signer.directory = certificates;
        final signer = Signer(wwdrPem: wwdrPem, certificateP12: certP12);

        final manifest = File('${certificates.path}/manifest')
          ..createSync(recursive: true)
          ..writeAsStringSync('{}');

        await Future.wait([
          signer.generateKey(),
          signer.generateCertificate(),
        ]);

        await signer.generateSignature(manifest: manifest);

        expect(signer.signature.existsSync(), true);

        signer.signature.deleteSync(recursive: true);
        signer.certPem.deleteSync(recursive: true);
        signer.keyPem.deleteSync(recursive: true);
        manifest.deleteSync(recursive: true);
      });
    });
  });
}
