import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'core/wallet_platform_test.dart' as wallet_platform_tests;
import 'core/wallet_factory_test.dart' as wallet_factory_tests;
import 'core/file_manager_test.dart' as file_manager_tests;
import 'core/card_generator_test.dart' as card_generator_tests;
import 'models/wallet_card_test.dart' as wallet_card_tests;
import 'flutter_wallet_card_test.dart' as main_tests;
import 'helpers_test.dart' as helpers_tests;

void main() {
  group('Flutter Wallet Card - All Tests', () {
    group('Core Tests', () {
      wallet_platform_tests.main();
      wallet_factory_tests.main();
      file_manager_tests.main();
      card_generator_tests.main();
    });

    group('Model Tests', () {
      wallet_card_tests.main();
    });

    group('Main Library Tests', () {
      main_tests.main();
    });

    group('Helper Tests', () {
      helpers_tests.main();
    });
  });
}