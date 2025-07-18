import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/card_generator.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CardGenerator', () {
    late Directory tempDir;
    late WalletCard testCard;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('card_generator_test_');
      testCard = const WalletCard(
        id: 'test-card-123',
        type: WalletCardType.generic,
        platformData: {
          'passTypeIdentifier': 'pass.com.example.test',
          'teamIdentifier': 'TEAM123',
        },
        metadata: WalletCardMetadata(
          title: 'Test Card',
          description: 'A test wallet card',
          organizationName: 'Test Organization',
          serialNumber: 'TEST123',
        ),
        visuals: WalletCardVisuals(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF000000),
          labelColor: Color(0xFF666666),
        ),
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('AppleWalletGenerator', () {
      late AppleWalletGenerator generator;

      setUp(() {
        generator = AppleWalletGenerator();
      });

      test('should support .pkpass extension', () {
        expect(generator.supportedExtension, '.pkpass');
      });

      test('should validate required platform data', () {
        const invalidCard = WalletCard(
          id: 'invalid',
          type: WalletCardType.generic,
          platformData: {}, // Missing required fields
          metadata: WalletCardMetadata(
            title: 'Invalid Card',
            description: 'Missing required data',
            organizationName: 'Test Org',
            serialNumber: '12345',
          ),
          visuals: WalletCardVisuals(
            backgroundColor: Color(0xFFFFFFFF),
            foregroundColor: Color(0xFF000000),
          ),
        );

        expect(
          () => generator.validateCard(invalidCard),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should validate card successfully with required data', () {
        expect(() => generator.validateCard(testCard), returnsNormally);
      });

      test('should generate pass.json content', () {
        final passJson = generator.generatePassJson(testCard);

        expect(passJson['passTypeIdentifier'], 'pass.com.example.test');
        expect(passJson['teamIdentifier'], 'TEAM123');
        expect(passJson['serialNumber'], 'TEST123');
        expect(passJson['description'], 'A test wallet card');
        expect(passJson['organizationName'], 'Test Organization');
        expect(passJson['generic'], isNotNull);
      });

      test('should generate different pass types', () {
        final boardingPassCard =
            testCard.copyWith(type: WalletCardType.boardingPass);
        final couponCard = testCard.copyWith(type: WalletCardType.coupon);
        final eventCard = testCard.copyWith(type: WalletCardType.eventTicket);
        final storeCard = testCard.copyWith(type: WalletCardType.storeCard);

        final boardingJson = generator.generatePassJson(boardingPassCard);
        final couponJson = generator.generatePassJson(couponCard);
        final eventJson = generator.generatePassJson(eventCard);
        final storeJson = generator.generatePassJson(storeCard);

        expect(boardingJson['boardingPass'], isNotNull);
        expect(couponJson['coupon'], isNotNull);
        expect(eventJson['eventTicket'], isNotNull);
        expect(storeJson['storeCard'], isNotNull);
      });

      test('should generate file successfully', () async {
        final outputFile = File(path.join(tempDir.path, 'test.pkpass'));

        final result = await generator.generateFile(testCard, outputFile);

        expect(await result.exists(), isTrue);
        expect(result.path.endsWith('.pkpass'), isTrue);
        expect(await result.length(), greaterThan(0));
      });

      test('should handle colors correctly', () {
        final cardWithColors = testCard.copyWith(
          visuals: const WalletCardVisuals(
            backgroundColor: Color(0xFFFF0000),
            foregroundColor: Color(0xFF00FF00),
            labelColor: Color(0xFF0000FF),
          ),
        );

        final passJson = generator.generatePassJson(cardWithColors);

        expect(passJson['backgroundColor'], 'rgb(255,0,0)');
        expect(passJson['foregroundColor'], 'rgb(0,255,0)');
        expect(passJson['labelColor'], 'rgb(0,0,255)');
      });

      test('should handle locations', () {
        final cardWithLocation = testCard.copyWith(
          metadata: testCard.metadata.copyWith(
            locations: [
              const WalletCardLocation(
                latitude: 37.7749,
                longitude: -122.4194,
                altitude: 100.0,
                relevantText: 'Near San Francisco',
              ),
            ],
          ),
        );

        final passJson = generator.generatePassJson(cardWithLocation);
        final locations = passJson['locations'] as List;

        expect(locations.length, 1);
        expect(locations[0]['latitude'], 37.7749);
        expect(locations[0]['longitude'], -122.4194);
        expect(locations[0]['altitude'], 100.0);
        expect(locations[0]['relevantText'], 'Near San Francisco');
      });
    });

    group('GoogleWalletGenerator', () {
      late GoogleWalletGenerator generator;

      setUp(() {
        generator = GoogleWalletGenerator();
      });

      test('should support .json extension', () {
        expect(generator.supportedExtension, '.json');
      });

      test('should validate required platform data', () {
        const invalidCard = WalletCard(
          id: 'invalid',
          type: WalletCardType.generic,
          platformData: {}, // Missing required fields
          metadata: WalletCardMetadata(
            title: 'Invalid Card',
            description: 'Missing required data',
            organizationName: 'Test Org',
            serialNumber: '12345',
          ),
          visuals: WalletCardVisuals(
            backgroundColor: Color(0xFFFFFFFF),
            foregroundColor: Color(0xFF000000),
          ),
        );

        expect(
          () => generator.validateCard(invalidCard),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should validate card successfully with required data', () {
        final validCard = testCard.copyWith(
          platformData: {
            'issuerId': 'test-issuer-id',
            'classId': 'test-class-id',
          },
        );

        expect(() => generator.validateCard(validCard), returnsNormally);
      });

      test('should generate Google Wallet JSON content', () {
        final validCard = testCard.copyWith(
          platformData: {
            'issuerId': 'test-issuer-id',
            'classId': 'test-class-id',
          },
        );

        final walletJson = generator.generateWalletJson(validCard);

        expect(walletJson['id'], 'test-card-123');
        expect(walletJson['classId'], 'test-class-id');
        expect(walletJson['state'], 'ACTIVE');
        expect(walletJson['heroImage'], isNotNull);
        expect(walletJson['textModulesData'], isNotNull);
      });

      test('should generate file successfully', () async {
        final validCard = testCard.copyWith(
          platformData: {
            'issuerId': 'test-issuer-id',
            'classId': 'test-class-id',
          },
        );

        final outputFile = File(path.join(tempDir.path, 'test.json'));

        final result = await generator.generateFile(validCard, outputFile);

        expect(await result.exists(), isTrue);
        expect(result.path.endsWith('.json'), isTrue);
        expect(await result.length(), greaterThan(0));

        // Verify JSON content
        final content = await result.readAsString();
        final json = jsonDecode(content);
        expect(json['id'], 'test-card-123');
      });

      test('should handle colors correctly', () {
        final validCard = testCard.copyWith(
          platformData: {
            'issuerId': 'test-issuer-id',
            'classId': 'test-class-id',
          },
          visuals: const WalletCardVisuals(
            backgroundColor: Color(0xFFFF0000),
            foregroundColor: Color(0xFF00FF00),
          ),
        );

        final walletJson = generator.generateWalletJson(validCard);
        final heroImage = walletJson['heroImage'];

        expect(heroImage['contentDescription'], isNotNull);
      });

      test('should handle locations', () {
        final validCard = testCard.copyWith(
          platformData: {
            'issuerId': 'test-issuer-id',
            'classId': 'test-class-id',
          },
          metadata: testCard.metadata.copyWith(
            locations: [
              const WalletCardLocation(
                latitude: 37.7749,
                longitude: -122.4194,
                relevantText: 'Near San Francisco',
              ),
            ],
          ),
        );

        final walletJson = generator.generateWalletJson(validCard);
        final locations = walletJson['locations'] as List;

        expect(locations.length, 1);
        expect(locations[0]['latitude'], 37.7749);
        expect(locations[0]['longitude'], -122.4194);
      });
    });
  });
}

// Extension method for testing
extension WalletCardCopyWith on WalletCard {
  WalletCard copyWith({
    String? id,
    WalletCardType? type,
    Map<String, dynamic>? platformData,
    WalletCardMetadata? metadata,
    WalletCardVisuals? visuals,
    File? file,
  }) {
    return WalletCard(
      id: id ?? this.id,
      type: type ?? this.type,
      platformData: platformData ?? this.platformData,
      metadata: metadata ?? this.metadata,
      visuals: visuals ?? this.visuals,
      file: file ?? this.file,
    );
  }
}

extension WalletCardMetadataCopyWith on WalletCardMetadata {
  WalletCardMetadata copyWith({
    String? title,
    String? description,
    String? organizationName,
    String? serialNumber,
    DateTime? expirationDate,
    DateTime? relevantDate,
    List<WalletCardLocation>? locations,
    Map<String, String>? customFields,
  }) {
    return WalletCardMetadata(
      title: title ?? this.title,
      description: description ?? this.description,
      organizationName: organizationName ?? this.organizationName,
      serialNumber: serialNumber ?? this.serialNumber,
      expirationDate: expirationDate ?? this.expirationDate,
      relevantDate: relevantDate ?? this.relevantDate,
      locations: locations ?? this.locations,
      customFields: customFields ?? this.customFields,
    );
  }
}
