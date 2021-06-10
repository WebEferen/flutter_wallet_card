
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pass_flutter/pass_flutter.dart';

class FlutterWalletCard {
  static const MethodChannel _channel =
      const MethodChannel('flutter_wallet_card');

  static Future<void> createPassFromUri({
    required String scheme,
    required String host,
    required String path,
    required Map<String, dynamic> parameters,
    required VoidCallback onGenerateSuccess
  }) async {
    final Uri requestUri = Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: parameters
    );

    try {
      await Pass().deleteAll();
      PassFile passFile = await Pass().saveFromUrl(url: requestUri.toString());

      dynamic result = await _channel.invokeMethod('addWalletCard', { 'path': passFile.file.path });
      if (result) onGenerateSuccess();

    } catch(e) {
      throw new Exception(e);
    }
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
