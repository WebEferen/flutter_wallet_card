---
layout: default
title: Flutter Wallet Card
description: A unified Flutter plugin for adding cards to Apple Wallet and Google Wallet
---

# Flutter Wallet Card

[![pub package](https://img.shields.io/pub/v/flutter_wallet_card.svg)](https://pub.dev/packages/flutter_wallet_card)
[![GitHub](https://img.shields.io/github/license/WebEferen/flutter_wallet_card)](https://github.com/WebEferen/flutter_wallet_card/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/WebEferen/flutter_wallet_card)](https://github.com/WebEferen/flutter_wallet_card/stargazers)

A unified Flutter plugin that provides a consistent API for adding cards to both Apple Wallet (iOS) and Google Wallet (Android). This plugin simplifies wallet integration by offering a single interface for both platforms.

## ✨ Features

- 🔄 **Unified API** - Single interface for both iOS and Android
- 🍎 **Apple Wallet Support** - Native PassKit integration
- 🤖 **Google Wallet Support** - Google Wallet API integration
- 📱 **Cross-platform** - Works on both iOS and Android
- 🎨 **Rich Customization** - Support for colors, images, and metadata
- 🔒 **Type Safety** - Full TypeScript-like support with strong typing
- 📦 **Easy Integration** - Simple setup and usage

## 🚀 Quick Start

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_wallet_card: ^4.0.0
```

Then run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';

// Check if wallet is available
bool isAvailable = await FlutterWalletCard.isWalletAvailable;

if (isAvailable) {
  // Create a wallet card
  final card = WalletCard(
    id: 'my-card-001',
    type: WalletCardType.storeCard,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.mycard',
      'teamIdentifier': 'YOUR_TEAM_ID',
    },
    metadata: WalletCardMetadata(
      title: 'My Store Card',
      organizationName: 'My Company',
      serialNumber: '001',
    ),
  );

  // Add to wallet
  await FlutterWalletCard.addToWallet(card);
}
```

## 📖 Documentation

- [Getting Started](getting-started.html)
- [API Reference](api-reference.html)
- [Platform Setup](platform-setup.html)
- [Examples](examples.html)
- [Migration Guide](migration.html)

## 🛠️ Platform Setup

### iOS (Apple Wallet)

1. Enable Wallet capability in Xcode
2. Configure your Pass Type ID
3. Set up certificates and provisioning profiles

[Detailed iOS Setup →](platform-setup.html#ios)

### Android (Google Wallet)

1. Set up Google Wallet API
2. Configure service account
3. Add required permissions

[Detailed Android Setup →](platform-setup.html#android)

## 🔄 Migration from v3.x

Version 4.0 introduces a unified API. If you're upgrading from v3.x:

**Old (v3.x):**
```dart
// iOS
await FlutterWalletCard.addPasskit(passData);

// Android
await FlutterWalletCard.addGoogleWallet(walletData);
```

**New (v4.0):**
```dart
// Unified API for both platforms
await FlutterWalletCard.addToWallet(walletCard);
```

[Complete Migration Guide →](migration.html)

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](https://github.com/WebEferen/flutter_wallet_card/blob/main/CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/WebEferen/flutter_wallet_card/blob/main/LICENSE) file for details.

## 🆘 Support

- [GitHub Issues](https://github.com/WebEferen/flutter_wallet_card/issues)
- [Discussions](https://github.com/WebEferen/flutter_wallet_card/discussions)
- [Documentation](https://webeferen.github.io/flutter_wallet_card/)