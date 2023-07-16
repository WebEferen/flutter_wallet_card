import 'package:flutter/services.dart';
import 'package:flutter_wallet_card/models/PasskitField.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';
import 'package:flutter_wallet_card/models/PasskitStructure.dart';

final ExamplePass = PasskitPass(
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
