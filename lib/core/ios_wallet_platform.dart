import 'dart:io';
import 'package:flutter/services.dart';
import 'wallet_platform.dart';

/// iOS-specific wallet platform implementation using Apple Wallet/PassKit
class IOSWalletPlatform implements WalletPlatform {
  static const MethodChannel _channel = MethodChannel('flutter_wallet_card');
  
  @override
  WalletPlatformType get platformType => WalletPlatformType.ios;
  
  @override
  Future<bool> isWalletAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isWalletAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to check wallet availability',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> isCardAdded(String identifier) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isWalletCardAdded',
        {'serialNumber': identifier},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to check if card is added',
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
      final result = await _channel.invokeMethod<bool>(
        'addWalletCard',
        {'path': file.path},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to add card to wallet',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> viewInWallet(String identifier) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'viewWalletCardInWallet',
        {'serialNumber': identifier},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to view card in wallet',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  /// Add multiple passes to wallet (iOS-specific feature)
  Future<bool> addMultipleToWallet(List<File> files) async {
    final paths = files.map((f) => f.path).toList();
    
    for (final file in files) {
      if (!file.existsSync()) {
        throw WalletException('File does not exist: ${file.path}');
      }
    }
    
    try {
      final result = await _channel.invokeMethod<bool>(
        'addMultipleWalletCards',
        {'paths': paths},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to add multiple cards to wallet',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  /// Add a pass from URL (iOS-specific feature)
  Future<bool> addFromUrl(String url) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'addWalletCardFromUrl',
        {'url': url},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to add card from URL',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  /// Validate a pass file without adding it to wallet
  Future<Map<String, dynamic>> validatePass(File file) async {
    if (!file.existsSync()) {
      throw WalletException('File does not exist: ${file.path}');
    }
    
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'validatePass',
        {'path': file.path},
      );
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to validate pass',
        code: e.code,
        originalError: e,
      );
    }
  }
  
  /// Get detailed information about a pass in the wallet
  Future<Map<String, dynamic>> getPassInfo(String identifier) async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getPassInfo',
        {'serialNumber': identifier},
      );
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw WalletException(
        'Failed to get pass info',
        code: e.code,
        originalError: e,
      );
    }
  }
}