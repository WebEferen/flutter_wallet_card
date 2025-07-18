import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';
import 'package:path_provider/path_provider.dart';

void generateWalletPassFromUri(String url) async {
  try {
    await FlutterWalletCard.addFromUrl(url);
  } catch (e) {
    print('Failed to add card from URL: $e');
  }
}

void generateWalletPassFromPath() async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/example.pkpass');

  final examplePass = await rootBundle.load('passes/example.pkpass');
  final written = await file.writeAsBytes(examplePass.buffer.asUint8List());

  try {
    await FlutterWalletCard.addFromFile(written);
  } catch (e) {
    print('Failed to add card from file: $e');
  }

  await file.delete();
}

// New iOS enhanced functions
void validatePassFile() async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/example.pkpass');

  final examplePass = await rootBundle.load('passes/example.pkpass');
  await file.writeAsBytes(examplePass.buffer.asUint8List());

  try {
    final result = await FlutterWalletCard.validatePass(file);
    print('Pass validation result: $result');
    _showDialog('Pass Validation',
        'Valid: ${result['isValid']}\nSerial: ${result['serialNumber']}\nOrg: ${result['organizationName']}');
  } catch (e) {
    print('Failed to validate pass: $e');
    _showDialog('Validation Error', e.toString());
  }

  await file.delete();
}

void getPassInformation() async {
  try {
    // First check if wallet is available
    final isAvailable = await FlutterWalletCard.isWalletAvailable;
    if (!isAvailable) {
      _showDialog('Wallet Not Available',
          'Apple Wallet is not available on this device');
      return;
    }

    // First validate the example pass to get its serial number
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/example.pkpass');
    final examplePass = await rootBundle.load('passes/example.pkpass');
    await file.writeAsBytes(examplePass.buffer.asUint8List());

    final validation = await FlutterWalletCard.validatePass(file);
    final serialNumber = validation['serialNumber'] as String;

    // Now try to get info for the pass using its actual serial number
    final result = await FlutterWalletCard.getPassInfo(serialNumber);
    print('Pass info: $result');
    _showDialog('Pass Information',
        'Serial: ${result['serialNumber']}\nOrg: ${result['organizationName']}\nExpired: ${result['isExpired']}');

    await file.delete();
  } catch (e) {
    print('Failed to get pass info: $e');
    _showDialog('Pass Info Error',
        'No passes found in wallet. Please add a pass first using the "Add apple pass" buttons above, then try again.\n\nError: ${e.toString()}');
  }
}

void checkPassValidity() async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/example.pkpass');

  final examplePass = await rootBundle.load('passes/example.pkpass');
  await file.writeAsBytes(examplePass.buffer.asUint8List());

  try {
    final isValid = await FlutterWalletCard.isValidPass(file);
    print('Pass is valid: $isValid');
    _showDialog(
        'Pass Validity Check', 'Pass is ${isValid ? 'valid' : 'invalid'}');
  } catch (e) {
    print('Failed to check pass validity: $e');
    _showDialog('Validity Check Error', e.toString());
  }

  await file.delete();
}

void _showDialog(String title, String message) {
  // Print to console for debugging
  print('$title: $message');

  // In a real app, you would show a proper CupertinoAlertDialog here
  // For this example, we'll just print to console since we don't have access to BuildContext
  // To implement proper dialogs, you'd need to pass BuildContext or use a global navigator key
}

final exampleUrl =
    'https://github.com/WebEferen/flutter_wallet_card/raw/master/example/passes/example.pkpass';

final exampleCard = WalletCard(
  id: 'example-card-001',
  type: WalletCardType.generic,
  platformData: {
    'description': 'Some description',
    'formatVersion': 1,
    'passTypeIdentifier': 'pass.com.suncern.wallet-example',
    'teamIdentifier': '6X23T5KB6N',
    'logoText': 'ACME Company',
  },
  metadata: WalletCardMetadata(
    title: 'Staff Card',
    description: 'Employee identification card',
    organizationName: 'ACME Company',
    serialNumber: '0000001',
  ),
  visuals: WalletCardVisuals(
    backgroundColor: Color(0xFF5A5A5A),
    foregroundColor: Color(0xFFFFFFFF),
    labelColor: Color(0xFFFFFFFF),
    logoText: 'ACME Company',
  ),
);
