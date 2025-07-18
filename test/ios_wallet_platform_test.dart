import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/ios_wallet_platform.dart';
import 'package:flutter_wallet_card/core/wallet_platform.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('IOSWalletPlatform Enhanced Methods', () {
    late IOSWalletPlatform platform;
    late List<MethodCall> methodCalls;

    setUp(() {
      platform = IOSWalletPlatform();
      methodCalls = [];
      
      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_wallet_card'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'addWalletCardFromUrl':
              return true;
            case 'validatePass':
              return {
                'isValid': true,
                'serialNumber': 'TEST123',
                'organizationName': 'Test Org',
                'description': 'Test Pass',
                'passTypeIdentifier': 'pass.com.test.example'
              };
            case 'getPassInfo':
              return {
                'serialNumber': 'TEST123',
                'organizationName': 'Test Org',
                'description': 'Test Pass',
                'passTypeIdentifier': 'pass.com.test.example',
                'relevantDate': null,
                'expirationDate': null,
                'isExpired': false,
                'passURL': 'shoebox://pass/TEST123'
              };
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_wallet_card'),
        null,
      );
    });

    test('should add pass from URL', () async {
      const testUrl = 'https://example.com/test.pkpass';
      
      final result = await platform.addFromUrl(testUrl);
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls[0].method, equals('addWalletCardFromUrl'));
      expect(methodCalls[0].arguments, equals({'url': testUrl}));
    });

    test('should validate pass file', () async {
      // Create a temporary test file
      final tempDir = Directory.systemTemp.createTempSync('wallet_test');
      final testFile = File('${tempDir.path}/test.pkpass');
      await testFile.writeAsString('test pass content');
      
      try {
        final result = await platform.validatePass(testFile);
        
        expect(result['isValid'], isTrue);
        expect(result['serialNumber'], equals('TEST123'));
        expect(result['organizationName'], equals('Test Org'));
        expect(methodCalls.length, equals(1));
        expect(methodCalls[0].method, equals('validatePass'));
        expect(methodCalls[0].arguments, equals({'path': testFile.path}));
      } finally {
        // Clean up
        await tempDir.delete(recursive: true);
      }
    });

    test('should get pass info', () async {
      const serialNumber = 'TEST123';
      
      final result = await platform.getPassInfo(serialNumber);
      
      expect(result['serialNumber'], equals('TEST123'));
      expect(result['organizationName'], equals('Test Org'));
      expect(result['isExpired'], isFalse);
      expect(result['passURL'], equals('shoebox://pass/TEST123'));
      expect(methodCalls.length, equals(1));
      expect(methodCalls[0].method, equals('getPassInfo'));
      expect(methodCalls[0].arguments, equals({'serialNumber': serialNumber}));
    });

    test('should handle validation of non-existent file', () async {
      final nonExistentFile = File('/non/existent/path/test.pkpass');
      
      expect(
        () => platform.validatePass(nonExistentFile),
        throwsA(isA<WalletException>()),
      );
    });

    test('should handle platform exceptions', () async {
      // Mock a platform exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_wallet_card'),
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error message',
          );
        },
      );
      
      expect(
        () => platform.addFromUrl('https://example.com/test.pkpass'),
        throwsA(isA<WalletException>()),
      );
    });
  });
}