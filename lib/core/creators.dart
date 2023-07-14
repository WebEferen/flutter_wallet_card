import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

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

  File _saveFile(String filename, String content) {
    return File('${directory!.path}/$filename')
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }
}
