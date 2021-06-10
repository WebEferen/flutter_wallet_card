import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wallet_card/flutter_wallet_card.dart';

// @GenerateMocks([Pass, Dio])
void main() {
  const MethodChannel channel = MethodChannel('flutter_wallet_card');
  const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  TestWidgetsFlutterBinding.ensureInitialized();

  group('checkPlatformVersion', () {
    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return '42';
      });
    });

    test('getPlatformVersion', () async {
      expect(await FlutterWalletCard.platformVersion, '42');
    });

    tearDown(() {
      channel.setMockMethodCallHandler(null);
    });
  });

  group('createPass', () {
    // final mockPass = MockPass();
    // final mockDio = MockDio();

    final Uri mockUri = Uri(
        scheme: 'https',
        host: 'passkit-test.herokuapp.com',
        path: '/api/wallet',
        queryParameters: {
          'code': 'somecodeqr',
          'holder': 'John Doe'
        }
    );

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return (methodCall.method == 'addWalletCard' && methodCall.arguments['path'] != null) ? true : false;
      });

      pathProviderChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
      });
    });

    test('successfully createPassFromUri', () async {
      // final String passId = 'somePassId';
      // final Directory passDir = Directory('passes');
      // final File passFile = File('${passDir.path}/$passId.passkit');

      // final PassFile mockPassFile = PassFile(
      //     id: passId,
      //     file: passFile,
      //     directory: passDir,
      //     pass: PassJson(
      //         description: 'somePassFileDescription',
      //         formatVersion: 1,
      //         organizationName: 'SomeOrganization',
      //         passTypeIdentifier: 'SomeIdentifier',
      //         serialNumber: 'SomeSerialNumber',
      //         teamIdentifier: 'SomeTeamIdentifier',
      //         barcodes: []
      //     )
      // );

      // when(mockDio.request(mockUri.toString())).thenAnswer((realInvocation) async =>
      //     Response(requestOptions: RequestOptions(path: mockUri.toString()), statusCode: 200));
      // when(mockPass.saveFromUrl(url: mockUri.toString())).thenAnswer((_) => Future.value(mockPassFile));
      //

      bool isSuccess = await FlutterWalletCard.createPassFromUri(
          scheme: mockUri.scheme,
          host: mockUri.host,
          path: mockUri.path,
          parameters: mockUri.queryParameters
      );

      expect(isSuccess, true);
    });

    tearDown(() {
      channel.setMockMethodCallHandler(null);
      pathProviderChannel.setMockMethodCallHandler(null);
    });
  });
}
