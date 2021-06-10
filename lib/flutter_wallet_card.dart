import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pass_flutter/pass_flutter.dart';

class FlutterWalletCard {
  static const MethodChannel _channel =
      const MethodChannel('flutter_wallet_card');

  static Future<bool> createPassFromUri({
    required String scheme,
    required String host,
    required String path,
    Map<String, dynamic>? parameters
  }) async {
    if (parameters == null) parameters = new Map();

    final Uri requestUri = Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: parameters
    );

    try {
      PassFile passFile = await Pass().saveFromUrl(url: requestUri.toString());
      dynamic result = await _channel.invokeMethod('addWalletCard', { 'path': passFile.file.path });

      passFile.delete();

      return (result != null && result) ? true : false;
    } catch(e) {
      throw new Exception(e);
    }
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
