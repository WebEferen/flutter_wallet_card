import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/wallet_platform.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';
import 'dart:ui';

void main() {
  group('WalletPlatformType', () {
    test('should have correct values', () {
      expect(WalletPlatformType.ios.name, 'ios');
      expect(WalletPlatformType.android.name, 'android');
      expect(WalletPlatformType.unsupported.name, 'unsupported');
    });
  });

  group('WalletException', () {
    test('should create exception with message', () {
      const message = 'Test error';
      final exception = WalletException(message);
      
      expect(exception.message, message);
      expect(exception.toString(), 'WalletException: $message');
    });

    test('should create exception with message and code', () {
      const message = 'Test error';
      const code = 'TEST_ERROR';
      final exception = WalletException(message, code: code);
      
      expect(exception.message, message);
      expect(exception.code, code);
      expect(exception.toString(), 'WalletException: $message (Code: $code)');
    });
  });

  group('WalletPlatform', () {
    late TestWalletPlatform platform;

    setUp(() {
      platform = TestWalletPlatform();
    });

    test('should implement all required methods', () {
      expect(platform.isWalletAvailable(), isA<Future<bool>>());
      expect(platform.isCardAdded('test'), isA<Future<bool>>());
      expect(platform.addToWallet(File('test.pkpass')), isA<Future<bool>>());
      expect(platform.viewInWallet('test'), isA<Future<bool>>());
    });
  });
}

class TestWalletPlatform extends WalletPlatform {
  @override
  Future<bool> isWalletAvailable() async => true;

  @override
  Future<bool> isCardAdded(String cardId) async => false;

  @override
  Future<bool> addToWallet(File file, {Map<String, dynamic>? metadata}) async => true;

  @override
  WalletPlatformType get platformType => WalletPlatformType.unsupported;

  @override
  Future<bool> viewInWallet(String cardId) async => true;
}

WalletCard createTestCard() {
  return WalletCard(
    id: 'test-id',
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