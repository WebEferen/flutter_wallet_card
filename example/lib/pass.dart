import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_wallet_card/models/PasskitField.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';
import 'package:flutter_wallet_card/models/PasskitStructure.dart';

// This is fixed signature, to work with passes, visit this link (and generate following signature):
// https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/YourFirst.html#//apple_ref/doc/uid/TP40012195-CH2-SW1
// https://www.kodeco.com/2855-beginning-passbook-in-ios-6-part-1-2
// Every change in the code below (inside generateWalletPass) will cause pass not rendering.
final SIGNATURE = File('signature.example').readAsBytesSync();

final EXAMPLE_PASS = PasskitPass(
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
