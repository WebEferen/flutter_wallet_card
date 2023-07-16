import 'dart:convert';
import 'dart:io';

import 'package:flutter_wallet_card/models/PasskitFile.dart';
import 'package:flutter_wallet_card/models/PasskitImage.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';

class Parser {
  final String id;
  final Directory directory;
  final File file;
  final File passFile;

  const Parser({
    required this.id,
    required this.directory,
    required this.file,
    required this.passFile,
  });

  Future<PasskitFile> parse() async {
    final json = await _parseJson();

    final logo = _retrieveImage(name: 'logo');
    final background = _retrieveImage(name: 'background');
    final strip = _retrieveImage(name: 'strip');
    final thumbnail = _retrieveImage(name: 'thumbnail');
    final footer = _retrieveImage(name: 'footer');
    final icon = _retrieveImage(name: 'icon');

    return PasskitFile(
      id: id,
      file: file,
      directory: directory,
      json: json,
      logo: logo,
      background: background,
      strip: strip,
      thumbnail: thumbnail,
      footer: footer,
      icon: icon,
    );
  }

  Future<PasskitPass> _parseJson() async {
    if (!passFile.existsSync()) throw Exception('Parser: pass.json not found');

    final json =
        jsonDecode(passFile.readAsStringSync()) as Map<String, dynamic>;
    return PasskitPass.fromJson(json);
  }

  PasskitImage _retrieveImage({required String name}) {
    final image = File('${directory.path}/$name.png');
    final image2x = File('${directory.path}/$name@2x.png');
    final image3x = File('${directory.path}/$name@3x.png');

    return PasskitImage(
      image: image.existsSync() ? image : null,
      image2x: image2x.existsSync() ? image2x : null,
      image3x: image3x.existsSync() ? image3x : null,
    );
  }
}
