import 'dart:io';

import 'package:flutter_wallet_card/models/PasskitFile.dart';

class PasskitGenerated {
  final PasskitFile passkitFile;
  final File manifestFile;
  final File passFile;
  final Directory directory;

  PasskitGenerated({
    required this.passkitFile,
    required this.manifestFile,
    required this.passFile,
    required this.directory,
  });
}
