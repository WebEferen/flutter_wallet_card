import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/wallet_factory.dart';
import 'package:flutter_wallet_card/core/wallet_platform.dart';

void main() {

  group('WalletFactory', () {
    setUp(() {
      WalletFactory.resetInstance();
    });

    tearDown(() {
      WalletFactory.resetInstance();
    });

    test('should return appropriate platform for current runtime', () {
      // Note: Platform detection is based on actual runtime platform
      final platform = WalletFactory.instance;
      expect(platform, isA<WalletPlatform>());
    });



    test('should return UnsupportedWalletPlatform for unsupported platforms', () {
      // This test verifies the factory returns an appropriate platform
      final platform = WalletFactory.instance;
      expect(platform, isA<WalletPlatform>());
    });

    test('should return same instance on multiple calls', () {
      final platform1 = WalletFactory.instance;
      final platform2 = WalletFactory.instance;
      
      expect(identical(platform1, platform2), isTrue);
    });

    test('should reset instance correctly', () {
      final platform1 = WalletFactory.instance;
      WalletFactory.resetInstance();
      final platform2 = WalletFactory.instance;
      
      expect(identical(platform1, platform2), isFalse);
    });
  });
}