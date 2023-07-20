import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallet_card/models/PasskitImage.dart';

import 'package:flutter_wallet_card/models/PasskitPass.dart';

class Creators {
  final Directory? directory;

  Creators({required this.directory});

  Future<File> createPass(PasskitPass pass) async {
    final escapedPass = pass.toJson()..removeWhere((_, value) => value == null);
    final encodedString = jsonEncode(escapedPass);

    return _saveFile('pass.json', encodedString);
  }

  Future<File> createManifest(Map<String, Uint8List> entries) async {
    final encodedString = jsonEncode(entries.map(
      (key, value) => MapEntry(key, sha1.convert(value).toString()),
    ));

    return _saveFile('manifest.json', encodedString);
  }

  Future<File> createEmptySignature() async {
    return _saveFile('signature', '');
  }

  Future<File> preparePkpass(String id) async {
    final file = File('${directory!.parent.path}/$id.pkpass');
    return file;
  }

  Future<List<File>> copyImage(
    PasskitImage image, {
    required String name,
    String extension = 'png',
  }) async {
    return Future.wait([
      if (image.image != null)
        image.image!.copy('${directory!.path}/$name.$extension'),
      if (image.image2x != null)
        image.image2x!.copy('${directory!.path}/$name@2x.$extension'),
      if (image.image3x != null)
        image.image3x!.copy('${directory!.path}/$name@3x.$extension'),
    ]);
  }

  File _saveFile(String filename, String content) {
    return File('${directory!.path}/$filename')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }
}
