import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import '../models/wallet_card.dart';
import 'wallet_platform.dart';
import 'file_manager.dart';

/// Abstract base class for card generators
abstract class CardGenerator {
  final FileManager fileManager;

  CardGenerator({FileManager? fileManager})
      : fileManager = fileManager ?? FileManager();

  /// Generate a wallet card file
  Future<File> generateCard(WalletCard card);

  /// Validate card data
  void validateCard(WalletCard card);

  /// Get the file extension for this card type
  String get fileExtension;
}

/// Apple Wallet pass generator
class AppleWalletGenerator extends CardGenerator {
  AppleWalletGenerator({super.fileManager});

  @override
  String get fileExtension => '.pkpass';

  /// Alias for fileExtension for backward compatibility
  String get supportedExtension => fileExtension;

  @override
  Future<File> generateCard(WalletCard card) async {
    validateCard(card);

    try {
      // Create temporary directory for pass contents
      final tempDir =
          await fileManager.createTempDirectory('apple_pass_${card.id}');

      // Generate pass.json
      final passJson = _generatePassJson(card);
      final passFile = File(path.join(tempDir.path, 'pass.json'));
      await passFile.writeAsString(jsonEncode(passJson));

      // Copy images if available
      await _copyImages(card, tempDir);

      // Generate manifest.json
      final manifestFile = await _generateManifest(tempDir);

      // Create empty signature file (actual signing should be implemented with certificates)
      final signatureFile = File(path.join(tempDir.path, 'signature'));
      await signatureFile.writeAsString('');

      // Create .pkpass file
      final outputFile =
          await fileManager.createOutputFile('${card.id}$fileExtension');
      await _createPkpassArchive(tempDir, outputFile);

      // Cleanup temp directory
      await tempDir.delete(recursive: true);

      return outputFile;
    } catch (e) {
      throw WalletException('Failed to generate Apple Wallet pass: $e');
    }
  }

  /// Generate Apple Wallet file to specific output file
  Future<File> generateFile(WalletCard card, File outputFile) async {
    validateCard(card);

    try {
      // Create temporary directory for pass contents
      final tempDir =
          await Directory.systemTemp.createTemp('apple_pass_${card.id}');

      // Generate pass.json
      final passJson = _generatePassJson(card);
      final passFile = File(path.join(tempDir.path, 'pass.json'));
      await passFile.writeAsString(jsonEncode(passJson));

      // Copy images if available
      await _copyImages(card, tempDir);

      // Generate manifest.json
      final manifestFile = await _generateManifest(tempDir);

      // Create empty signature file (actual signing should be implemented with certificates)
      final signatureFile = File(path.join(tempDir.path, 'signature'));
      await signatureFile.writeAsString('');

      // Create .pkpass file
      await _createPkpassArchive(tempDir, outputFile);

      // Cleanup temp directory
      await tempDir.delete(recursive: true);

      return outputFile;
    } catch (e) {
      throw WalletException('Failed to generate Apple Wallet file: $e');
    }
  }

  /// Generate Apple Wallet pass JSON for testing purposes
  Map<String, dynamic> generatePassJson(WalletCard card) {
    return _generatePassJson(card);
  }

  @override
  void validateCard(WalletCard card) {
    if (card.metadata.serialNumber.isEmpty) {
      throw ArgumentError('Serial number is required for Apple Wallet passes');
    }

    if (card.metadata.organizationName.isEmpty) {
      throw ArgumentError(
          'Organization name is required for Apple Wallet passes');
    }

    // Check for required platform-specific data
    final platformData = card.platformData;
    if (!platformData.containsKey('passTypeIdentifier')) {
      throw ArgumentError(
          'passTypeIdentifier is required for Apple Wallet passes');
    }

    if (!platformData.containsKey('teamIdentifier')) {
      throw ArgumentError('teamIdentifier is required for Apple Wallet passes');
    }
  }

  Map<String, dynamic> _generatePassJson(WalletCard card) {
    final json = <String, dynamic>{
      'formatVersion': 1,
      'passTypeIdentifier': card.platformData['passTypeIdentifier'],
      'serialNumber': card.metadata.serialNumber,
      'teamIdentifier': card.platformData['teamIdentifier'],
      'organizationName': card.metadata.organizationName,
      'description': card.metadata.description ?? card.metadata.title,
    };

    // Add visual elements
    if (card.visuals != null) {
      final visuals = card.visuals!;
      if (visuals.backgroundColor != null) {
        json['backgroundColor'] = _colorToRgbString(visuals.backgroundColor!);
      }
      if (visuals.foregroundColor != null) {
        json['foregroundColor'] = _colorToRgbString(visuals.foregroundColor!);
      }
      if (visuals.labelColor != null) {
        json['labelColor'] = _colorToRgbString(visuals.labelColor!);
      }
      if (visuals.logoText != null) {
        json['logoText'] = visuals.logoText;
      }
    }

    // Add card type specific structure
    final cardStructure = _generateCardStructure(card);
    json[card.type.name] = cardStructure;

    // Add optional fields
    if (card.metadata.expirationDate != null) {
      json['expirationDate'] = card.metadata.expirationDate!.toIso8601String();
    }

    if (card.metadata.relevantDate != null) {
      json['relevantDate'] = card.metadata.relevantDate!.toIso8601String();
    }

    if (card.metadata.locations != null &&
        card.metadata.locations!.isNotEmpty) {
      json['locations'] = card.metadata.locations!
          .map((loc) => {
                'latitude': loc.latitude,
                'longitude': loc.longitude,
                if (loc.altitude != null) 'altitude': loc.altitude,
                if (loc.relevantText != null) 'relevantText': loc.relevantText,
              })
          .toList();
    }

    // Add custom platform data
    json.addAll(card.platformData);

    return json;
  }

  Map<String, dynamic> _generateCardStructure(WalletCard card) {
    final structure = <String, dynamic>{};

    // Add primary fields
    if (card.metadata.title.isNotEmpty) {
      structure['primaryFields'] = [
        {
          'key': 'title',
          'label': 'Title',
          'value': card.metadata.title,
        }
      ];
    }

    // Add secondary fields
    final secondaryFields = <Map<String, dynamic>>[];
    if (card.metadata.subtitle != null) {
      secondaryFields.add({
        'key': 'subtitle',
        'label': 'Subtitle',
        'value': card.metadata.subtitle,
      });
    }

    // Add custom fields
    if (card.metadata.customFields != null) {
      card.metadata.customFields!.forEach((key, value) {
        secondaryFields.add({
          'key': key,
          'label': key.replaceAll('_', ' ').toUpperCase(),
          'value': value,
        });
      });
    }

    if (secondaryFields.isNotEmpty) {
      structure['secondaryFields'] = secondaryFields;
    }

    return structure;
  }

  String _colorToRgbString(dynamic color) {
    if (color is String) return color;
    // Assuming color is a Flutter Color object
    if (color.runtimeType.toString().contains('Color')) {
      // Extract RGB values from Color object
      final colorValue = color.value as int;
      final r = (colorValue >> 16) & 0xFF;
      final g = (colorValue >> 8) & 0xFF;
      final b = colorValue & 0xFF;
      return 'rgb($r,$g,$b)';
    }
    return color.toString();
  }

  Future<void> _copyImages(WalletCard card, Directory tempDir) async {
    if (card.visuals?.images == null) return;

    for (final entry in card.visuals!.images!.entries) {
      final imageType = entry.key;
      final imagePath = entry.value;
      final sourceFile = File(imagePath);

      if (sourceFile.existsSync()) {
        final targetFile = File(path.join(tempDir.path, '$imageType.png'));
        await sourceFile.copy(targetFile.path);
      }
    }
  }

  Future<File> _generateManifest(Directory tempDir) async {
    final manifest = <String, String>{};

    await for (final entity in tempDir.list()) {
      if (entity is File && path.basename(entity.path) != 'manifest.json') {
        final bytes = await entity.readAsBytes();
        final hash = sha1.convert(bytes).toString();
        manifest[path.basename(entity.path)] = hash;
      }
    }

    final manifestFile = File(path.join(tempDir.path, 'manifest.json'));
    await manifestFile.writeAsString(jsonEncode(manifest));
    return manifestFile;
  }

  Future<void> _createPkpassArchive(
      Directory sourceDir, File outputFile) async {
    final encoder = ZipFileEncoder();
    encoder.zipDirectory(sourceDir, filename: outputFile.path);
  }
}

/// Google Wallet card generator
class GoogleWalletGenerator extends CardGenerator {
  GoogleWalletGenerator({super.fileManager});

  @override
  String get fileExtension => '.json';

  /// Alias for fileExtension for backward compatibility
  String get supportedExtension => fileExtension;

  @override
  Future<File> generateCard(WalletCard card) async {
    validateCard(card);

    try {
      final cardJson = _generateGoogleWalletJson(card);
      final outputFile =
          await fileManager.createOutputFile('${card.id}$fileExtension');
      await outputFile.writeAsString(jsonEncode(cardJson));
      return outputFile;
    } catch (e) {
      throw WalletException('Failed to generate Google Wallet card: $e');
    }
  }

  @override
  void validateCard(WalletCard card) {
    if (card.id.isEmpty) {
      throw ArgumentError('ID is required for Google Wallet cards');
    }

    // Check for required platform-specific data
    final platformData = card.platformData;
    if (!platformData.containsKey('issuerId')) {
      throw ArgumentError('issuerId is required for Google Wallet cards');
    }

    if (!platformData.containsKey('classId')) {
      throw ArgumentError('classId is required for Google Wallet cards');
    }
  }

  /// Generate Google Wallet JSON for testing purposes
  Map<String, dynamic> generateWalletJson(WalletCard card) {
    return _generateGoogleWalletJson(card);
  }

  /// Generate Google Wallet file to specific output file
  Future<File> generateFile(WalletCard card, File outputFile) async {
    validateCard(card);

    try {
      final cardJson = _generateGoogleWalletJson(card);
      await outputFile.writeAsString(jsonEncode(cardJson));
      return outputFile;
    } catch (e) {
      throw WalletException('Failed to generate Google Wallet file: $e');
    }
  }

  Map<String, dynamic> _generateGoogleWalletJson(WalletCard card) {
    final json = <String, dynamic>{
      'id': card.id,
      'classId': card.platformData['classId'],
      'state': 'ACTIVE',
    };

    // Add card type specific data
    switch (card.type) {
      case WalletCardType.loyalty:
        json['loyaltyPoints'] = {
          'label': 'Points',
          'balance': {'string': card.platformData['points']?.toString() ?? '0'}
        };
        break;
      case WalletCardType.generic:
        json['cardTitle'] = {
          'defaultValue': {'language': 'en-US', 'value': card.metadata.title}
        };
        break;
      default:
        // Handle other card types
        break;
    }

    // Add text modules for additional information
    final textModules = <Map<String, dynamic>>[];

    if (card.metadata.subtitle != null) {
      textModules.add({
        'header': 'Subtitle',
        'body': card.metadata.subtitle,
      });
    }

    if (card.metadata.description != null) {
      textModules.add({
        'header': 'Description',
        'body': card.metadata.description,
      });
    }

    if (textModules.isNotEmpty) {
      json['textModulesData'] = textModules;
    }

    // Add hero image with content description
    json['heroImage'] = {
      'contentDescription': card.metadata.description ?? card.metadata.title,
    };

    // Add locations if available
    if (card.metadata.locations != null &&
        card.metadata.locations!.isNotEmpty) {
      json['locations'] = card.metadata.locations!
          .map((location) => {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'relevantText': location.relevantText,
              })
          .toList();
    }

    // Add custom platform data
    json.addAll(card.platformData);

    return json;
  }
}
