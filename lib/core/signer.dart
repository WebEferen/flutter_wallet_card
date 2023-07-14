import 'dart:io';
import 'package:cli_script/cli_script.dart';
import 'package:flutter/services.dart';

class Signer {
  static Directory directory = Directory('certificates');

  final File wwdrPem;
  final File certificateP12;

  final File certPem = File('${directory.path}/cert.pem');
  final File keyPem = File('${directory.path}/key.pem');
  final File signature = File('${directory.path}/signature');

  Signer({
    required this.wwdrPem,
    required this.certificateP12,
  }) {
    if (!wwdrPem.existsSync()) throw Exception('Missing wwdr.pem');
    if (!certificateP12.existsSync()) throw Exception('Missing cert.p12');

    isOpenSSLSupported().then((isSupported) =>
        {if (!isSupported) throw Exception('OpenSSL is not supported!')});
  }

  static Future<bool> isOpenSSLSupported() async {
    final response = await output('which openssl');
    return (response.isNotEmpty) ? true : false;
  }

  Future<File> generateCertificate() async {
    final arguments = [
      '-in "${certificateP12.path}"',
      '-clcerts',
      '-nokeys',
      '-out "${certPem.path}"',
      '-passin pass:'
    ];

    await run('openssl pkcs12 ${arguments.join(' ')}');
    return certPem;
  }

  Future<File> generateKey({String password = '12345'}) async {
    final arguments = [
      '-in "${certificateP12.path}"',
      '-nocerts',
      '-out "${keyPem.path}"',
      '-passin pass:',
      '-passout pass:$password'
    ];

    await run('openssl pkcs12 ${arguments.join(' ')}');
    return keyPem;
  }

  Future<File> generateSignature({
    required File manifest,
    String password = '12345',
  }) async {
    if (!certPem.existsSync()) throw Exception('Missing cert.pem');
    if (!keyPem.existsSync()) throw Exception('Missing key.pem');

    final arguments = [
      '-in "${manifest.path}"',
      '-out "${signature.path}"',
      '-certfile "${wwdrPem.path}"',
      '-signer "${certPem.path}"',
      '-inkey "${keyPem.path}"',
      '-passin pass:$password',
      '-outform DER',
      '-binary',
      '-sign',
    ];

    await run('openssl smime ${arguments.join(' ')}');
    return signature;
  }

  Uint8List getSignature() {
    final signature = File('${directory.path}/signature');
    if (!signature.existsSync()) throw Exception('Signature file is missing!');

    return signature.readAsBytesSync();
  }
}
