import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_wallet_card/core/passkit.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/PasskitField.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';
import 'package:flutter_wallet_card/models/PasskitStructure.dart';
import 'package:path_provider/path_provider.dart';

void generateWalletPassFromUri(String url) async {
  final passkit = await Passkit().saveFromUri(id: 'example', url: url);
  await FlutterWalletCard.addPasskit(passkit);
}

void generateWalletPassFromPath() async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/example.pkpass');

  final examplePass = await rootBundle.load('passes/example.pkpass');
  final written = await file.writeAsBytes(examplePass.buffer.asUint8List());

  final passkit = await Passkit().saveFromPath(id: 'example', file: written);
  await FlutterWalletCard.addPasskit(passkit);

  await file.delete();
}

final exampleUrl =
    'https://github.com/WebEferen/flutter_wallet_card/raw/v3/example/passes/example.pkpass';

final examplePass = PasskitPass(
  description: 'Some description',
  formatVersion: 1,
  organizationName: 'Michal Makowski',
  passTypeIdentifier: 'pass.com.suncern.wallet-example',
  serialNumber: '0000001',
  teamIdentifier: '6X23T5KB6N',
  logoText: "ACME Company",
  foregroundColor: Color.fromRGBO(255, 255, 255, 1),
  backgroundColor: Color.fromRGBO(90, 90, 90, 1),
  labelColor: Color.fromRGBO(255, 255, 255, 1),
  generic: PasskitStructure(
    primaryFields: [
      PasskitField(
        key: 'holder',
        label: 'Holder',
        value: 'John Doe',
      )
    ],
    headerFields: [
      PasskitField(
        key: 'staffNumber',
        value: '001',
        label: 'Staff Number',
      )
    ],
  ),
);
