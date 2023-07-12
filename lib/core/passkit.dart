import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as Path;

import 'package:flutter_wallet_card/core/fs.dart';
import 'package:flutter_wallet_card/core/parser.dart';
import 'package:flutter_wallet_card/models/PasskitFile.dart';
import 'package:flutter_wallet_card/models/PasskitImage.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';

class Passkit {
  final Fs fs = Fs();
  final String directoryName;

  Passkit({this.directoryName = 'passes'});

  Future<void> purgePasses() async {
    final root = await fs.createDirectory(name: directoryName);
    root.deleteSync(recursive: true);
  }

  Future<PasskitFile> generate({
    required String id,
    required Uint8List signature,
    required PasskitPass pass,
    PasskitImage? backgroundImage,
    PasskitImage? footerImage,
    PasskitImage? iconImage,
    PasskitImage? logoImage,
    PasskitImage? stripImage,
    PasskitImage? thumbnailImage,
    bool override = false,
  }) async {
    final root = await fs.createDirectory(name: directoryName);

    // Create child directory and pass.json file
    final directory = Directory('${root.path}/$id');
    if (directory.existsSync()) {
      if (!override) throw Exception('Passkit exists!');
      directory.deleteSync(recursive: true);
    }

    // Create pass.json file
    final escapedPass = pass.toJson()..removeWhere((_, value) => value == null);
    final passFile = File('${directory.path}/pass.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(jsonEncode(escapedPass));

    // Logo & icon files - TODO: Remove because we have logo and icon already
    final examplesDirectory = Directory('test/fixtures/example_passkit');
    final logoFile = File(Path.absolute('${examplesDirectory.path}/logo.png'));
    final iconFile = File(Path.absolute('${examplesDirectory.path}/icon.png'));
    logoFile.copySync('${directory.path}/logo.png');
    iconFile.copySync('${directory.path}/icon.png');

    // Create manifest.json file with checksums - TODO: Use existing *Image
    File('${directory.path}/manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(jsonEncode({
        "pass.json": sha1.convert(passFile.readAsBytesSync()).toString(),
        "logo.png": sha1.convert(logoFile.readAsBytesSync()).toString(),
        "icon.png": sha1.convert(iconFile.readAsBytesSync()).toString(),
      }));

    File('${directory.path}/signature')
      ..createSync(recursive: true)
      ..writeAsBytesSync(signature);

    // Pack directory into zip (.pkpass)
    final pkpass = File('${root.path}/$id.pkpass');
    if (pkpass.existsSync()) {
      if (!override) throw Exception('Pkpass exists!');
      pkpass.deleteSync(recursive: true);
    }

    // Pack & remove old files
    fs.pack(directory: directory, filename: pkpass.path);
    directory.deleteSync(recursive: true);

    return PasskitFile(
      id: id,
      file: pkpass,
      directory: directory,
      json: pass,
      background: backgroundImage,
      footer: footerImage,
      icon: iconImage,
      logo: logoImage,
      strip: stripImage,
      thumbnail: thumbnailImage,
    );
  }

  Future<PasskitFile> saveFromPath({
    required String id,
    required File file,
  }) async {
    final directory = await fs.createDirectory(name: directoryName);
    final passkitDirectory = Directory(Path.withoutExtension(file.path));

    if (directory.path == Path.dirname(file.path)) {
      throw Exception('This file has already been saved.');
    }

    if (!file.existsSync()) {
      throw Exception('Unable to fetch pass file at specified path');
    }

    file.copySync('${directory.path}/$id.passkit');
    await fs.unpack(path: '${directory.path}/$id.passkit');

    final passkitFile = File('${directory.path}/$id/pass.json');
    if (!passkitFile.existsSync()) throw Exception('Missing pass.json');

    return Parser(
      id: id,
      directory: passkitDirectory,
      file: passkitFile,
    ).parse();
  }

  Future<PasskitFile> saveFromUri(
      {required String id, required String url}) async {
    Directory directory = await fs.createDirectory(name: directoryName);
    final file = File('${directory.path}/$id.pkpass')..createSync();

    directory = Directory(Path.withoutExtension(file.path));
    final response = await Dio().download(url, file.path);

    if (response.statusCode != 200) {
      throw new Exception('Unable to download passkit');
    }

    await fs.unpack(path: file.path);

    final passkitFile = File('${directory.path}/pass.json');
    if (!passkitFile.existsSync()) throw Exception('Missing pass.json');

    return Parser(id: id, directory: directory, file: passkitFile).parse();
  }
}
