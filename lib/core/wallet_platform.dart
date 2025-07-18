import 'dart:io';

/// Abstract interface for wallet platform operations
abstract class WalletPlatform {
  /// Check if wallet is available on the current platform
  Future<bool> isWalletAvailable();
  
  /// Check if a specific card/pass is already added to the wallet
  Future<bool> isCardAdded(String identifier);
  
  /// Add a card/pass to the wallet
  Future<bool> addToWallet(File file, {Map<String, dynamic>? metadata});
  
  /// View a specific card/pass in the wallet
  Future<bool> viewInWallet(String identifier);
  
  /// Get the platform type
  WalletPlatformType get platformType;
}

/// Supported wallet platform types
enum WalletPlatformType {
  ios,
  android,
  unsupported,
}

/// Exception thrown when wallet operations fail
class WalletException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const WalletException(this.message, {this.code, this.originalError});
  
  @override
  String toString() => 'WalletException: $message${code != null ? ' (Code: $code)' : ''}';
}