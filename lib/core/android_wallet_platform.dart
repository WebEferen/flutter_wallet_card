import 'dart:io';
import 'package:flutter/services.dart';
import 'wallet_platform.dart';

/// Android-specific wallet platform implementation using Google Wallet
class AndroidWalletPlatform implements WalletPlatform {
  static const MethodChannel _channel = MethodChannel('flutter_wallet_card');
  
  @override
  WalletPlatformType get platformType => WalletPlatformType.android;
  
  @override
  Future<bool> isWalletAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isGoogleWalletAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to check Google Wallet availability',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> isCardAdded(String identifier) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isGoogleWalletCardAdded',
        {'objectId': identifier},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to check if card is added to Google Wallet',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> addToWallet(File file, {Map<String, dynamic>? metadata}) async {
    if (!file.existsSync()) {
      throw WalletException('File does not exist: ${file.path}');
    }
    
    try {
      final args = {
        'path': file.path,
        if (metadata != null) ...metadata,
      };
      
      final result = await _channel.invokeMethod<bool>(
        'addGoogleWalletCard',
        args,
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to add card to Google Wallet',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> viewInWallet(String identifier) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'viewGoogleWalletCard',
        {'objectId': identifier},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to view card in Google Wallet',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  /// Save a pass to Google Wallet using JWT (Android-specific)
  Future<bool> savePassWithJwt(String jwt) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'saveGoogleWalletPassWithJwt',
        {'jwt': jwt},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to save pass with JWT to Google Wallet',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  /// Create a Google Wallet pass link
  Future<String> createPassLink(Map<String, dynamic> passData) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'createGoogleWalletPassLink',
        passData,
      );
      return result ?? '';
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to create Google Wallet pass link',
        code: e.code,
        originalError: e,
      );
    }
  }
}