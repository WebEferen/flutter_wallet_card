import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'core/wallet_factory.dart';
import 'core/wallet_platform.dart';
import 'core/card_generator.dart';
import 'core/file_manager.dart';
import 'models/wallet_card.dart';

/// Main Flutter Wallet Card plugin class
///
/// Provides a unified API for working with wallet cards on both iOS (Apple Wallet)
/// and Android (Google Wallet) platforms.
class FlutterWalletCard {
  static final WalletPlatform _platform = WalletFactory.instance;
  static final FileManager _fileManager = FileManager();

  /// Check if wallet functionality is available on the current platform
  static Future<bool> get isWalletAvailable => _platform.isWalletAvailable();

  /// Get the current platform type
  static WalletPlatformType get platformType => _platform.platformType;

  /// Check if a specific card is already added to the wallet
  ///
  /// [identifier] - The card identifier (serial number for iOS, object ID for Android)
  static Future<bool> isCardAdded(String identifier) {
    return _platform.isCardAdded(identifier);
  }

  /// Add a wallet card to the platform's wallet
  ///
  /// [card] - The wallet card to add
  /// Returns true if the card was successfully added
  static Future<bool> addToWallet(WalletCard card) async {
    try {
      final generator = _getGeneratorForPlatform();
      final file = await generator.generateCard(card);

      final metadata = {
        'cardType': card.type.name,
        'organizationName': card.metadata.organizationName,
        'serialNumber': card.metadata.serialNumber,
      };

      return await _platform.addToWallet(file, metadata: metadata);
    } catch (e) {
      if (kDebugMode) {
        print('FlutterWalletCard: Failed to add card to wallet: $e');
      }
      rethrow;
    }
  }

  /// Add a wallet card from an existing file
  ///
  /// [file] - The wallet card file (.pkpass for iOS, .json for Android)
  /// [metadata] - Optional metadata for the card
  static Future<bool> addFromFile(File file, {Map<String, dynamic>? metadata}) {
    if (!_fileManager.isValidWalletFile(file)) {
      throw WalletException('Invalid wallet file format: ${file.path}');
    }

    return _platform.addToWallet(file, metadata: metadata);
  }

  /// Generate a wallet card file without adding it to the wallet
  ///
  /// [card] - The wallet card to generate
  /// Returns the generated file
  static Future<File> generateCardFile(WalletCard card) async {
    final generator = _getGeneratorForPlatform();
    return await generator.generateCard(card);
  }

  /// Download and add a wallet card from a URL
  ///
  /// [url] - The URL to download the wallet card from
  /// [metadata] - Optional metadata for the card
  static Future<bool> addFromUrl(String url,
      {Map<String, dynamic>? metadata}) async {
    try {
      // Use native iOS implementation if available
      if (_platform.platformType == WalletPlatformType.ios) {
        final iosWallet = _platform as dynamic;
        if (iosWallet.addFromUrl != null) {
          return await iosWallet.addFromUrl(url);
        }
      }

      // Fallback to download and add
      final file = await _fileManager.downloadFile(url);
      return await addFromFile(file, metadata: metadata);
    } catch (e) {
      if (kDebugMode) {
        print('FlutterWalletCard: Failed to add card from URL: $e');
      }
      rethrow;
    }
  }

  /// View a specific card in the wallet
  ///
  /// [identifier] - The card identifier (serial number for iOS, object ID for Android)
  static Future<bool> viewInWallet(String identifier) {
    return _platform.viewInWallet(identifier);
  }

  /// Parse a wallet card from an existing file
  ///
  /// [file] - The wallet card file to parse
  /// Returns the parsed wallet card
  static Future<WalletCard> parseFromFile(File file) async {
    if (!file.existsSync()) {
      throw WalletException('File does not exist: ${file.path}');
    }

    if (!_fileManager.isValidWalletFile(file)) {
      throw WalletException('Invalid wallet file format: ${file.path}');
    }

    try {
      if (file.path.endsWith('.pkpass')) {
        return await _parseAppleWalletPass(file);
      } else if (file.path.endsWith('.json')) {
        return await _parseGoogleWalletCard(file);
      } else {
        throw const WalletException('Unsupported file format');
      }
    } catch (e) {
      throw WalletException('Failed to parse wallet card: $e');
    }
  }

  /// Clean up temporary files and old downloads
  ///
  /// [olderThan] - Delete files older than this duration (default: 7 days)
  static Future<void> cleanup({Duration? olderThan}) {
    return _fileManager.cleanup(olderThan: olderThan);
  }

  /// iOS-specific: Add multiple passes to the wallet
  ///
  /// [cards] - List of wallet cards to add
  /// Only works on iOS platform
  static Future<bool> addMultipleToWallet(List<WalletCard> cards) async {
    if (_platform.platformType != WalletPlatformType.ios) {
      throw const WalletException(
          'Multiple card addition is only supported on iOS');
    }

    try {
      final generator = AppleWalletGenerator(fileManager: _fileManager);
      final files = <File>[];

      for (final card in cards) {
        final file = await generator.generateCard(card);
        files.add(file);
      }

      // Use iOS-specific method
      final iosWallet = _platform as dynamic;
      return await iosWallet.addMultipleToWallet(files);
    } catch (e) {
      if (kDebugMode) {
        print('FlutterWalletCard: Failed to add multiple cards: $e');
      }
      rethrow;
    }
  }

  /// Android-specific: Save a pass using JWT
  ///
  /// [jwt] - The JWT token for the Google Wallet pass
  /// Only works on Android platform
  static Future<bool> savePassWithJwt(String jwt) async {
    if (_platform.platformType != WalletPlatformType.android) {
      throw const WalletException(
          'JWT pass saving is only supported on Android');
    }

    try {
      final androidWallet = _platform as dynamic;
      return await androidWallet.savePassWithJwt(jwt);
    } catch (e) {
      if (kDebugMode) {
        print('FlutterWalletCard: Failed to save pass with JWT: $e');
      }
      rethrow;
    }
  }

  /// Android-specific: Create a Google Wallet pass link
  ///
  /// [passData] - The pass data for creating the link
  /// Only works on Android platform
  static Future<String> createPassLink(Map<String, dynamic> passData) async {
    if (_platform.platformType != WalletPlatformType.android) {
      throw const WalletException(
          'Pass link creation is only supported on Android');
    }

    try {
      final androidWallet = _platform as dynamic;
      return await androidWallet.createPassLink(passData);
    } catch (e) {
      if (kDebugMode) {
        print('FlutterWalletCard: Failed to create pass link: $e');
      }
      rethrow;
    }
  }

  /// iOS-specific: Validate a pass file without adding it to wallet
  ///
  /// [file] - The pass file to validate
  /// Returns validation result with pass information
  static Future<Map<String, dynamic>> validatePass(File file) async {
    if (_platform.platformType != WalletPlatformType.ios) {
      throw const WalletException('Pass validation is only supported on iOS');
    }

    try {
      final iosWallet = _platform as dynamic;
      return await iosWallet.validatePass(file);
    } catch (e) {
      if (kDebugMode) {
        print('FlutterWalletCard: Failed to validate pass: $e');
      }
      rethrow;
    }
  }

  /// iOS-specific: Get detailed information about a pass in the wallet
  ///
  /// [identifier] - The pass identifier (serial number)
  /// Returns detailed pass information
  static Future<Map<String, dynamic>> getPassInfo(String identifier) async {
    if (_platform.platformType != WalletPlatformType.ios) {
      throw const WalletException(
          'Pass info retrieval is only supported on iOS');
    }

    try {
      final iosWallet = _platform as dynamic;
      return await iosWallet.getPassInfo(identifier);
    } catch (e) {
      if (kDebugMode) {
        print('FlutterWalletCard: Failed to get pass info: $e');
      }
      rethrow;
    }
  }

  /// iOS-specific: Check if a pass file is valid
  ///
  /// [file] - The pass file to check
  /// Returns true if the pass is valid
  static Future<bool> isValidPass(File file) async {
    if (_platform.platformType != WalletPlatformType.ios) {
      // For non-iOS platforms, use basic file validation
      return _fileManager.isValidWalletFile(file);
    }

    try {
      final validation = await validatePass(file);
      return validation['isValid'] == true;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods

  static CardGenerator _getGeneratorForPlatform() {
    switch (_platform.platformType) {
      case WalletPlatformType.ios:
        return AppleWalletGenerator(fileManager: _fileManager);
      case WalletPlatformType.android:
        return GoogleWalletGenerator(fileManager: _fileManager);
      case WalletPlatformType.unsupported:
        throw const WalletException(
            'Wallet operations are not supported on this platform');
    }
  }

  static Future<WalletCard> _parseAppleWalletPass(File file) async {
    // Extract the .pkpass file
    final extractedDir = await _fileManager.extractArchive(file);

    try {
      // Read pass.json
      final passJsonFile = File('${extractedDir.path}/pass.json');
      if (!passJsonFile.existsSync()) {
        throw const WalletException('Invalid .pkpass file: missing pass.json');
      }

      final passJsonContent = await passJsonFile.readAsString();
      final passJson =
          Map<String, dynamic>.from(await compute(_parseJson, passJsonContent));

      // Convert to WalletCard
      return _convertApplePassToWalletCard(passJson, file);
    } finally {
      // Clean up extracted directory
      await extractedDir.delete(recursive: true);
    }
  }

  static Future<WalletCard> _parseGoogleWalletCard(File file) async {
    final jsonContent = await file.readAsString();
    final cardJson =
        Map<String, dynamic>.from(await compute(_parseJson, jsonContent));

    return _convertGoogleCardToWalletCard(cardJson, file);
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  static WalletCard _convertApplePassToWalletCard(
      Map<String, dynamic> passJson, File file) {
    // Convert Apple Wallet pass JSON to WalletCard
    // This is a simplified implementation
    return WalletCard(
      id: passJson['serialNumber'] ?? '',
      type: _getCardTypeFromApplePass(passJson),
      platformData: passJson,
      metadata: WalletCardMetadata(
        title: passJson['description'] ?? '',
        organizationName: passJson['organizationName'] ?? '',
        serialNumber: passJson['serialNumber'] ?? '',
      ),
      file: file,
    );
  }

  static WalletCard _convertGoogleCardToWalletCard(
      Map<String, dynamic> cardJson, File file) {
    // Convert Google Wallet card JSON to WalletCard
    // Extract title and description from textModulesData
    String title = '';
    String description = '';

    final textModules = cardJson['textModulesData'] as List<dynamic>?;
    if (textModules != null) {
      for (final module in textModules) {
        final header = module['header'] as String?;
        final body = module['body'] as String?;
        if (header == 'Title' && body != null) {
          title = body;
        } else if (header == 'Description' && body != null) {
          description = body;
        }
      }
    }

    return WalletCard(
      id: cardJson['id'] ?? '',
      type: WalletCardType.generic, // Default type
      platformData: cardJson,
      metadata: WalletCardMetadata(
        title: title,
        description: description,
        organizationName: cardJson['issuerName'] ?? '',
        serialNumber: cardJson['id'] ?? '',
      ),
      file: file,
    );
  }

  static WalletCardType _getCardTypeFromApplePass(
      Map<String, dynamic> passJson) {
    if (passJson.containsKey('storeCard')) return WalletCardType.storeCard;
    if (passJson.containsKey('eventTicket')) return WalletCardType.eventTicket;
    if (passJson.containsKey('boardingPass')) {
      return WalletCardType.boardingPass;
    }
    if (passJson.containsKey('coupon')) return WalletCardType.coupon;
    return WalletCardType.generic;
  }
}
