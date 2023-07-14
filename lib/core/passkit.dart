import 'dart:io';
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
    required final String id,
    required final Directory directory,
    required final PasskitPass passkitPass,
    PasskitImage? backgroundImage,
    PasskitImage? footerImage,
    PasskitImage? iconImage,
    PasskitImage? logoImage,
    PasskitImage? stripImage,
    PasskitImage? thumbnailImage,
    bool override = false,
  }) async {
    // Create child directory
    final childDirectory = Directory('${directory.path}/$id');
    if (childDirectory.existsSync()) {
      if (!override) throw Exception('Passkit exists!');
      childDirectory.deleteSync(recursive: true);
    }

    // Pack directory into zip (.pkpass)
    final pkpass = File('${directory.path}/$id.pkpass');
    if (pkpass.existsSync()) {
      if (!override) throw Exception('Pkpass exists!');
      pkpass.deleteSync(recursive: true);
    }

    // Pack & remove old files
    fs.pack(directory: directory, filename: pkpass.path);

    return PasskitFile(
      id: id,
      file: pkpass,
      directory: childDirectory,
      json: passkitPass,
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
    final childDirectory = Directory(Path.withoutExtension(file.path));

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
      directory: childDirectory,
      file: passkitFile,
    ).parse();
  }

  Future<PasskitFile> saveFromUri({
    required String id,
    required String url,
  }) async {
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
