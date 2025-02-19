[![Flutter Build Actions](https://github.com/WebEferen/flutter_wallet_card/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/WebEferen/flutter_wallet_card/actions/workflows/main.yml)
[![Pub Package](https://img.shields.io/pub/v/flutter_wallet_card.svg)](https://pub.dartlang.org/packages/flutter_wallet_card)

# flutter_wallet_card

Flutter plugin which allows users to create their own Apple Wallet Passes (as well as Google Cards).

## Getting Started

### Fetch from URL

Provide URL object for the `.passkit` file (hosted on www). Library will automatically download it, unpack and add to Apple Wallet if the passkit is valid. It saves all the passkits inside Application Directory and the directory is cleared when next pass is added to save device memory.

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';

/// It returns [PasskitFile] object
final passkitFile = await FlutterWalletCard.generateFromUri(
  scheme: 'https',
  host: 'example.com',
  path: '/wallet.pkpass',
  parameters: {
    'someQueryParameter': 'someQueryValue'
  }
);
```

### Fetch from file

Provide absolute path to the `.passkit` file. Library will automatically unpack it add prepare object that will be ready to add into Apple Wallet if the passkit is valid. It saves all the passkits inside Application Directory and the directory is cleared when next pass is added to save device memory.

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';

/// It returns [PasskitFile] object
final passkitFile = await FlutterWalletCard.generateFromFile(
  id: 'example-pass',
  file: File('path-to-file.pkpass'),
);
```

### Generate from scratch

Currently there is no way to generate signature within mobile application althrough, You can find `Signer` class that is using `OpenSSL` under-the-hood which allows to generate such a signature certificate. On real device unfortunately, there is no possibility to generate it (yet). For more information check Signer class reference.

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';

final passkitGenerated = await FlutterWalletCard.generatePass(
  id: 'example-id',
  pass: PasskitPass(), // class instance
  signature: File('signature'),
  manifest: File('manifest.json'),
  iconImage: PasskitImage(), // class instance
);

final passkitFile = passkitGenerated.passkitFile;
```

### Save it into wallet

Once the `passkitFile` will be generated, use this command to add it into Apple Wallet. This command will return if the pass was added or not.

```dart
/// It accepts [PasskitFile] class instance and returns [bool]
final completed = await FlutterWalletCard.addPasskit(passkitFile);
```

### View in wallet

Once the `passkitFile` will be generated, use this command to view it in the Apple Wallet. This command will return status whether operation succeeded or not.

```dart
/// It accepts [String] class instance and returns [bool]
final completed = await FlutterWalletCard.viewPassInWalletv('<serial-number>');


```

## Contribute

Please feel free to fork, improve, make pull requests or fill issues.
I'll be glad to fix bugs you encountered or improve the extension.

## Roadmap

At this moment some of key features are not working as intended to:

- [ ] Add support for in-app passport generation

## Changelog

Refer to the [Changelog](https://github.com/webeferen/flutter_wallet_card/blob/master/CHANGELOG.md) to get all release notes.
