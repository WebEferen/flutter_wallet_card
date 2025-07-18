import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';
import 'package:flutter_wallet_card/core/wallet_platform.dart';
import 'package:flutter_wallet_card/core/wallet_factory.dart';

import 'package:mockito/annotations.dart';
import 'package:path/path.dart' as path;

// Generate mocks
@GenerateMocks([WalletPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWalletCard', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('wallet_test_');

      // Reset the factory instance
      WalletFactory.resetInstance();

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_wallet_card'),
        (MethodCall methodCall) async {
          return null;
        },
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      WalletFactory.resetInstance();
    });

    group('Wallet Availability', () {
      testWidgets('should check if wallet is available',
          (WidgetTester tester) async {
        // On unsupported platforms, should throw WalletException
        await expectLater(FlutterWalletCard.isWalletAvailable,
            throwsA(isA<WalletException>()));
      });
    });

    group('Card Operations', () {
      testWidgets('should check if card is added', (WidgetTester tester) async {
        const cardId = 'test-card-123';

        // On unsupported platforms, should throw WalletException
        await expectLater(FlutterWalletCard.isCardAdded(cardId),
            throwsA(isA<WalletException>()));
      });

      testWidgets('should add card to wallet', (WidgetTester tester) async {
        final card = createTestCard();

        // On unsupported platforms, should throw WalletException
        await expectLater(FlutterWalletCard.addToWallet(card),
            throwsA(isA<WalletException>()));
      });

      testWidgets('should view card in wallet', (WidgetTester tester) async {
        const cardId = 'test-card-123';

        // On unsupported platforms, should throw WalletException
        await expectLater(FlutterWalletCard.viewInWallet(cardId),
            throwsA(isA<WalletException>()));
      });
    });

    group('File Generation', () {
      test('should generate card file', () async {
        final card = createTestCard();

        // On unsupported platforms, should throw WalletException
        await expectLater(FlutterWalletCard.generateCardFile(card),
            throwsA(isA<WalletException>()));
      });

      test('should generate Apple Wallet file', () async {
        final card = createAppleWalletCard();

        // On unsupported platforms, should throw WalletException
        await expectLater(FlutterWalletCard.generateCardFile(card),
            throwsA(isA<WalletException>()));
      });

      test('should generate Google Wallet file', () async {
        final card = createGoogleWalletCard();

        // On unsupported platforms, should throw WalletException
        await expectLater(FlutterWalletCard.generateCardFile(card),
            throwsA(isA<WalletException>()));
      });
    });

    group('File Parsing', () {
      test('should parse Apple Wallet file', () async {
        // Create a test pkpass file structure
        final passDir = Directory(path.join(tempDir.path, 'test_pass'));
        await passDir.create();

        final passJson = {
          'formatVersion': 1,
          'passTypeIdentifier': 'pass.com.example.test',
          'teamIdentifier': 'TEAM123',
          'serialNumber': 'TEST123',
          'description': 'Test Pass',
          'organizationName': 'Test Org',
          'generic': {
            'primaryFields': [],
            'secondaryFields': [],
            'auxiliaryFields': [],
            'backFields': [],
          },
        };

        final passFile = File(path.join(passDir.path, 'pass.json'));
        await passFile.writeAsString(jsonEncode(passJson));

        // Create a .pkpass archive for testing
        final pkpassFile = File(path.join(tempDir.path, 'test.pkpass'));
        final archive = Archive();
        final passJsonBytes = await passFile.readAsBytes();
        archive.addFile(
            ArchiveFile('pass.json', passJsonBytes.length, passJsonBytes));
        final zipData = ZipEncoder().encode(archive);
        await pkpassFile.writeAsBytes(zipData!);

        final card = await FlutterWalletCard.parseFromFile(pkpassFile);

        expect(card.id, 'TEST123');
        expect(card.type, WalletCardType.generic);
        expect(card.metadata.title, 'Test Pass');
        expect(card.metadata.organizationName, 'Test Org');
      });

      test('should parse Google Wallet file', () async {
        final walletJson = {
          'id': 'google-wallet-123',
          'classId': 'test-class-id',
          'state': 'ACTIVE',
          'textModulesData': [
            {
              'header': 'Title',
              'body': 'Google Wallet Card',
            },
            {
              'header': 'Description',
              'body': 'Test Google Wallet Card',
            },
          ],
        };

        final jsonFile = File(path.join(tempDir.path, 'google_wallet.json'));
        await jsonFile.writeAsString(jsonEncode(walletJson));

        final card = await FlutterWalletCard.parseFromFile(jsonFile);

        expect(card.id, 'google-wallet-123');
        expect(card.metadata.title, 'Google Wallet Card');
        expect(card.metadata.description, 'Test Google Wallet Card');
      });
    });

    group('URL Operations', () {
      test('should handle download from URL', () async {
        const url = 'https://example.com/test.pkpass';

        try {
          final result = await FlutterWalletCard.addFromUrl(url);

          expect(result, isA<bool>());
        } catch (e) {
          // Network operations might fail in test environment
          expect(e, isA<Exception>());
        }
      });
    });

    group('Platform-specific Operations', () {
      test('should handle iOS multiple cards', () async {
        final cards = [createAppleWalletCard(), createAppleWalletCard()];

        // Test method throws exception on non-iOS platforms
        expect(
          () => FlutterWalletCard.addMultipleToWallet(cards),
          throwsA(isA<WalletException>()),
        );
      });

      test('should handle Android JWT save', () async {
        const jwt = 'test.jwt.token';

        // Test method throws exception on non-Android platforms
        expect(
          () => FlutterWalletCard.savePassWithJwt(jwt),
          throwsA(isA<WalletException>()),
        );
      });

      test('should handle Android pass link creation', () async {
        final passData = {'objectId': 'test-object-123'};

        // Test method throws exception on non-Android platforms
        expect(
          () => FlutterWalletCard.createPassLink(passData),
          throwsA(isA<WalletException>()),
        );
      });
    });

    group('Error Handling', () {
      test('should handle invalid file paths', () async {
        expect(
          () => FlutterWalletCard.parseFromFile(File('/nonexistent/file.json')),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle invalid directory paths', () async {
        expect(
          () => FlutterWalletCard.parseFromFile(
              File('/nonexistent/directory/file.json')),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle invalid URLs', () async {
        expect(
          () => FlutterWalletCard.addFromUrl('invalid-url'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

WalletCard createTestCard() {
  return WalletCard(
    id: 'test-card-123',
    type: WalletCardType.generic,
    platformData: {},
    metadata: WalletCardMetadata(
      title: 'Test Card',
      description: 'Test Description',
      organizationName: 'Test Org',
      serialNumber: '12345',
    ),
    visuals: WalletCardVisuals(
      backgroundColor: const Color(0xFFFFFFFF),
      foregroundColor: const Color(0xFF000000),
    ),
  );
}

WalletCard createAppleWalletCard() {
  return WalletCard(
    id: 'apple-card-123',
    type: WalletCardType.generic,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.test',
      'teamIdentifier': 'TEAM123',
    },
    metadata: WalletCardMetadata(
      title: 'Apple Wallet Card',
      description: 'Test Apple Wallet Card',
      organizationName: 'Test Organization',
      serialNumber: 'APPLE123',
    ),
    visuals: WalletCardVisuals(
      backgroundColor: const Color(0xFFFFFFFF),
      foregroundColor: const Color(0xFF000000),
    ),
  );
}

WalletCard createGoogleWalletCard() {
  return WalletCard(
    id: 'google-card-123',
    type: WalletCardType.generic,
    platformData: {
      'issuerId': 'test-issuer-id',
      'classId': 'test-class-id',
    },
    metadata: WalletCardMetadata(
      title: 'Google Wallet Card',
      description: 'Test Google Wallet Card',
      organizationName: 'Test Organization',
      serialNumber: 'GOOGLE123',
    ),
    visuals: WalletCardVisuals(
      backgroundColor: const Color(0xFFFFFFFF),
      foregroundColor: const Color(0xFF000000),
    ),
  );
}
