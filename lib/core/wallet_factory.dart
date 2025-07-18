import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'wallet_platform.dart';
import 'ios_wallet_platform.dart';
import 'android_wallet_platform.dart';

/// Factory class for creating platform-specific wallet implementations
class WalletFactory {
  static WalletPlatform? _instance;
  
  /// Get the appropriate wallet platform implementation for the current platform
  static WalletPlatform get instance {
    _instance ??= _createPlatformInstance();
    return _instance!;
  }
  
  /// Create platform-specific wallet implementation
  static WalletPlatform _createPlatformInstance() {
    if (kIsWeb) {
      return UnsupportedWalletPlatform();
    }
    
    if (io.Platform.isIOS) {
      return IOSWalletPlatform();
    }
    
    if (io.Platform.isAndroid) {
      return AndroidWalletPlatform();
    }
    
    return UnsupportedWalletPlatform();
  }
  
  /// Reset the instance (useful for testing)
  static void reset() {
    _instance = null;
  }
  
  /// Reset the instance (alias for reset, useful for testing)
  static void resetInstance() {
    reset();
  }
  
  /// Set a custom wallet platform (useful for testing)
  static void setCustomPlatform(WalletPlatform platform) {
    _instance = platform;
  }
}

/// Unsupported platform implementation
class UnsupportedWalletPlatform implements WalletPlatform {
  @override
  WalletPlatformType get platformType => WalletPlatformType.unsupported;
  
  @override
  Future<bool> isWalletAvailable() async {
    throw WalletException('Wallet operations are not supported on this platform');
  }
  
  @override
  Future<bool> isCardAdded(String identifier) async {
    throw WalletException('Wallet operations are not supported on this platform');
  }
  
  @override
  Future<bool> addToWallet(io.File file, {Map<String, dynamic>? metadata}) async {
    throw WalletException('Wallet operations are not supported on this platform');
  }
  
  @override
  Future<bool> viewInWallet(String identifier) async {
    throw WalletException('Wallet operations are not supported on this platform');
  }
}