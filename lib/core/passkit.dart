import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_wallet_card/core/creators.dart';
import 'package:flutter_wallet_card/models/PasskitGenerated.dart';
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

  Future<PasskitGenerated> generate({
    required final String id,
    required final Directory directory,
    required final PasskitPass passkitPass,
    required final File pkpass,
    PasskitImage? backgroundImage,
    PasskitImage? footerImage,
    PasskitImage? iconImage,
    PasskitImage? logoImage,
    PasskitImage? stripImage,
    PasskitImage? thumbnailImage,
    bool override = false,
  }) async {
    final fs = Fs();
    final directory = await fs.createDirectory(name: 'passes');
    final childDirectory = Directory('${directory.path}/$id');
    final creators = Creators(directory: childDirectory);
    final pkpass = File('${directory.path}/$id.pkpass');

    await Future.wait([
      if (iconImage != null) creators.copyImage(iconImage, name: 'icon'),
      if (logoImage != null) creators.copyImage(logoImage, name: 'logo'),
      if (footerImage != null) creators.copyImage(footerImage, name: 'footer'),
      if (stripImage != null) creators.copyImage(stripImage, name: 'stripe'),
      if (thumbnailImage != null)
        creators.copyImage(thumbnailImage, name: 'thumbnail'),
      if (backgroundImage != null)
        creators.copyImage(backgroundImage, name: 'background'),
    ]);

    final pkpassFile = await creators.preparePkpass(id);
    final passFile = await creators.createPass(passkitPass);
    final manifestFile = await creators.createManifest({
      'pass.json': passFile.readAsBytesSync(),
    });

    final passkitFile = PasskitFile(
      id: id,
      file: pkpass,
      directory: directory,
      json: passkitPass,
      background: backgroundImage,
      footer: footerImage,
      icon: iconImage,
      logo: logoImage,
      strip: stripImage,
      thumbnail: thumbnailImage,
    );

    fs.pack(directory: childDirectory, filename: pkpassFile.path);

    return PasskitGenerated(
      directory: childDirectory,
      passkitFile: passkitFile,
      manifestFile: manifestFile,
      passFile: passFile,
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

    final passFile = File('${directory.path}/$id/pass.json');
    if (!passFile.existsSync()) throw Exception('Missing pass.json');

    return Parser(
      id: id,
      directory: childDirectory,
      passFile: passFile,
      file: file,
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

    return Parser(
      id: id,
      directory: directory,
      file: file,
      passFile: passkitFile,
    ).parse();
  }
}
