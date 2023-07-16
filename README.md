[![Flutter Build Actions](https://github.com/WebEferen/flutter_wallet_card/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/WebEferen/flutter_wallet_card/actions/workflows/main.yml)
[![Pub Package](https://img.shields.io/pub/v/flutter_wallet_card.svg)](https://pub.dartlang.org/packages/flutter_wallet_card)

# flutter_wallet_card

Flutter plugin which allows users to create their own Apple Wallet Passes (as well as Google Cards).

## Getting Started

### Getting pass from URL and displays it on device

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';

bool isCardShown = await FlutterWalletCard.createPassFromUri(
  scheme: 'https',
  host: 'example.com',
  path: '/wallet.pkpass',
  parameters: {
    'someQueryParameter': 'someQueryValue'
  }
);
```

## Contribute

Please feel free to fork, improve, make pull requests or fill issues.
I'll be glad to fix bugs you encountered or improve the extension.

## Roadmap

At this moment some of key features are not working as intended to:

- [ ] Android Devices integration

## Changelog

Refer to the [Changelog](https://github.com/webeferen/flutter_wallet_card/blob/master/CHANGELOG.md) to get all release notes.
