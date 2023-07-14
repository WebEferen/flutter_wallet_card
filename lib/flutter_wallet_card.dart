import 'dart:async';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_wallet_card/core/creators.dart';
import 'package:flutter_wallet_card/core/fs.dart';
import 'package:flutter_wallet_card/core/passkit.dart';
import 'package:flutter_wallet_card/models/PasskitGenerated.dart';
import 'package:flutter_wallet_card/models/PasskitImage.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';
import 'package:flutter_wallet_card/models/PasskitFile.dart';

class FlutterWalletCard {
  static const MethodChannel _channel =
      const MethodChannel('flutter_wallet_card');

  static Future<PasskitGenerated> generatePass({
    required String id,
    required PasskitPass pass,
    String passesDirectory = 'passes',
    PasskitImage? backgroundImage,
    PasskitImage? footerImage,
    PasskitImage? iconImage,
    PasskitImage? logoImage,
    PasskitImage? stripImage,
    PasskitImage? thumbnailImage,
    bool deleteAfterwards = false,
    bool override = false,
  }) async {
    final fs = Fs();
    final directory = await fs.createDirectory(name: passesDirectory);
    final creators = Creators(directory: directory);

    final passFile = await creators.createPass(pass);
    final manifestFile = await creators.createManifest({
      'pass.json': passFile.readAsBytesSync(),
    });

    final passkitFile = await Passkit().generate(
      id: id,
      passkitPass: pass,
      directory: directory,
      backgroundImage: backgroundImage,
      footerImage: footerImage,
      iconImage: iconImage,
      logoImage: logoImage,
      stripImage: stripImage,
      thumbnailImage: thumbnailImage,
    );

    return PasskitGenerated(
      directory: directory,
      passkitFile: passkitFile,
      manifestFile: manifestFile,
      passFile: passFile,
    );
  }

  static Future<PasskitFile> generateFromUri({
    required String host,
    required String path,
    String scheme = 'https',
    bool deleteAfterwards = true,
    Map<String, dynamic>? parameters,
  }) async {
    final String id = Uuid().v4();
    final Uri uri = Uri(
      queryParameters: (parameters != null) ? parameters : new Map(),
      scheme: scheme,
      host: host,
      path: path,
    );

    return Passkit().saveFromUri(id: id, url: uri.toString());
  }

  static Future<bool> canAddToWallet() async {
    dynamic result = await _channel.invokeMethod('isWalletAvailable');
    return (result != null && result) ? true : false;
  }

  static Future<bool> isExisting(
    String passTypeIdentifier,
    String serialNumber,
  ) async {
    dynamic result = await _channel.invokeMethod('isWalletCardAdded', {
      'passTypeIdentifier': passTypeIdentifier,
      'serialNumber': serialNumber
    });

    return (result != null && result) ? true : false;
  }

  static Future<bool> addPasskit(PasskitFile passkit) async {
    final result = await _channel.invokeMethod('addWalletCard', {
      'path': passkit.file.path,
    });

    print(result);

    return (result != null && result);
  }

  static Future<void> purgePasses() async {
    await Passkit().purgePasses();
  }
}
