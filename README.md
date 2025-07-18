# Flutter Wallet Card

[![pub package](https://img.shields.io/pub/v/flutter_wallet_card.svg)](https://pub.dartlang.org/packages/flutter_wallet_card)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter plugin for creating and managing wallet cards on both iOS (Apple Wallet) and Android (Google Wallet). This plugin provides a unified API for generating, adding, and managing wallet passes across platforms.

## Features

### Cross-Platform Support
- **iOS**: Full Apple Wallet (Passkit) integration
- **Android**: Google Wallet integration
- **Unified API**: Single codebase for both platforms

### Card Operations
- ✅ Check wallet availability
- ✅ Add cards to wallet
- ✅ Check if card is already added
- ✅ View cards in wallet
- ✅ Generate card files from data
- ✅ Parse existing card files
- ✅ Download cards from URLs

### Card Types Supported
- **Generic Cards**: General purpose cards
- **Boarding Passes**: Flight tickets
- **Coupons**: Discount and promotional cards
- **Event Tickets**: Concert, sports, and event passes
- **Store Cards**: Loyalty and membership cards

### Advanced Features
- 🎨 Custom colors and styling
- 📍 Location-based relevance
- 📅 Date-based relevance
- 🔒 Secure certificate signing (iOS)
- 🌐 Network download support
- 🧪 Comprehensive test coverage

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_wallet_card: ^4.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### iOS Setup

1. **Enable Wallet capability** in your iOS project:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select your target → Signing & Capabilities
   - Add "Wallet" capability

2. **Configure your Apple Developer account**:
   - Create a Pass Type ID in Apple Developer Console
   - Generate certificates for pass signing

### Android Setup

1. **Add Google Wallet API** to your project:
   - Enable Google Wallet API in Google Cloud Console
   - Configure OAuth 2.0 credentials

2. **Update Android manifest** (automatically handled by plugin):
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

## Usage

### Basic Example

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';

// Check if wallet is available
bool isAvailable = await FlutterWalletCard.isWalletAvailable();

if (isAvailable) {
  // Create a wallet card
  final card = WalletCard(
    id: 'my-card-123',
    type: WalletCardType.generic,
    platformData: {
      // iOS specific data
      'passTypeIdentifier': 'pass.com.yourcompany.yourpass',
      'teamIdentifier': 'YOUR_TEAM_ID',
      // Android specific data
      'issuerId': 'your-issuer-id',
      'classId': 'your-class-id',
    },
    metadata: WalletCardMetadata(
      title: 'My Awesome Card',
      description: 'This is a sample wallet card',
      organizationName: 'Your Company',
      serialNumber: 'CARD123',
    ),
    visuals: WalletCardVisuals(
      backgroundColor: '#1E88E5',
      foregroundColor: '#FFFFFF',
      labelColor: '#E3F2FD',
    ),
  );

  // Add card to wallet
  bool success = await FlutterWalletCard.addToWallet(card);
  
  if (success) {
    print('Card added successfully!');
  }
}
```

### Advanced Usage

#### Creating Cards with Locations

```dart
final cardWithLocation = WalletCard(
  id: 'location-card',
  type: WalletCardType.storeCard,
  platformData: {
    'passTypeIdentifier': 'pass.com.yourcompany.store',
    'teamIdentifier': 'YOUR_TEAM_ID',
  },
  metadata: WalletCardMetadata(
    title: 'Store Loyalty Card',
    description: 'Get rewards at our store',
    organizationName: 'Your Store',
    locations: [
      WalletCardLocation(
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 100.0,
        relevantText: 'Welcome to our San Francisco store!',
      ),
    ],
  ),
  visuals: WalletCardVisuals(
    backgroundColor: '#4CAF50',
    foregroundColor: '#FFFFFF',
  ),
);
```

#### Generating Card Files

```dart
// Generate a card file for sharing or storage
File cardFile = await FlutterWalletCard.generateCardFile(
  card,
  outputDirectory: await getApplicationDocumentsDirectory(),
);

print('Card file created at: ${cardFile.path}');
```

#### Downloading Cards from URLs

```dart
// Download and add a card from a URL
try {
  File downloadedCard = await FlutterWalletCard.downloadFromUrl(
    'https://example.com/mycard.pkpass',
  );
  
  // Parse the downloaded card
  WalletCard card = await FlutterWalletCard.parseFromFile(downloadedCard.path);
  
  // Add to wallet
  await FlutterWalletCard.addToWallet(card);
} catch (e) {
  print('Failed to download card: $e');
}
```

#### Platform-Specific Features

```dart
// iOS: Add multiple cards at once
if (Platform.isIOS) {
  List<WalletCard> cards = [card1, card2, card3];
  bool success = await FlutterWalletCard.addMultipleToWallet(cards);
}

// Android: Save pass with JWT
if (Platform.isAndroid) {
  String jwt = 'your-google-wallet-jwt';
  bool success = await FlutterWalletCard.savePassWithJwt(jwt);
  
  // Create a pass link
  String link = await FlutterWalletCard.createPassLink({
    'objectId': 'your-object-id',
  });
}
```

## API Reference

### Core Methods

| Method | Description | Returns |
|--------|-------------|----------|
| `isWalletAvailable()` | Check if wallet is available on device | `Future<bool>` |
| `isCardAdded(String cardId)` | Check if specific card is added | `Future<bool>` |
| `addToWallet(WalletCard card)` | Add card to wallet | `Future<bool>` |
| `viewInWallet(String cardId)` | Open card in wallet app | `Future<bool>` |
| `generateCardFile(WalletCard card)` | Generate card file | `Future<File>` |
| `parseFromFile(String path)` | Parse card from file | `Future<WalletCard>` |
| `downloadFromUrl(String url)` | Download card from URL | `Future<File>` |

### iOS-Specific Methods

| Method | Description | Returns |
|--------|-------------|----------|
| `addMultipleToWallet(List<WalletCard> cards)` | Add multiple cards | `Future<bool>` |

### Android-Specific Methods

| Method | Description | Returns |
|--------|-------------|----------|
| `savePassWithJwt(String jwt)` | Save pass using JWT | `Future<bool>` |
| `createPassLink(Map<String, dynamic> data)` | Create pass link | `Future<String>` |

## Models

### WalletCard

The main model representing a wallet card:

```dart
class WalletCard {
  final String id;
  final WalletCardType type;
  final Map<String, dynamic> platformData;
  final WalletCardMetadata metadata;
  final WalletCardVisuals visuals;
  final File? file;
}
```

### WalletCardMetadata

Card information and content:

```dart
class WalletCardMetadata {
  final String title;
  final String description;
  final String? organizationName;
  final String? serialNumber;
  final DateTime? expirationDate;
  final DateTime? relevantDate;
  final List<WalletCardLocation>? locations;
  final Map<String, dynamic>? additionalData;
}
```

### WalletCardVisuals

Card appearance and styling:

```dart
class WalletCardVisuals {
  final String backgroundColor;
  final String foregroundColor;
  final String? labelColor;
  final Map<String, dynamic>? additionalStyles;
}
```

## Error Handling

The plugin throws `WalletException` for wallet-related errors:

```dart
try {
  await FlutterWalletCard.addToWallet(card);
} on WalletException catch (e) {
  print('Wallet error: ${e.message}');
  if (e.details != null) {
    print('Details: ${e.details}');
  }
} catch (e) {
  print('General error: $e');
}
```

## Testing

Run the test suite:

```bash
flutter test
```

For comprehensive testing:

```bash
flutter test test/test_all.dart
```

## Migration from v3.x

If you're upgrading from version 3.x, here are the key changes:

### Breaking Changes

1. **New unified API**: Replace platform-specific calls with unified methods
2. **Updated models**: Use new `WalletCard` model instead of separate iOS/Android models
3. **Method names**: Some method names have changed for consistency

### Migration Example

**Old (v3.x):**
```dart
// iOS
await FlutterWalletCard.addPasskit(passData);

// Android
await FlutterWalletCard.addGoogleWallet(walletData);
```

**New (v4.x):**
```dart
// Unified
final card = WalletCard(/* ... */);
await FlutterWalletCard.addToWallet(card);
```

## 📚 Documentation

For detailed documentation, examples, and API reference, visit our [documentation site](https://webeferen.github.io/flutter_wallet_card/).

### Quick Links
- [Getting Started Guide](https://webeferen.github.io/flutter_wallet_card/getting-started) - Setup and basic integration
- [API Reference](https://webeferen.github.io/flutter_wallet_card/api-reference) - Complete API documentation
- [Platform Setup](https://webeferen.github.io/flutter_wallet_card/platform-setup) - iOS and Android configuration
- [Examples](https://webeferen.github.io/flutter_wallet_card/examples) - Practical code examples
- [Migration Guide](https://webeferen.github.io/flutter_wallet_card/migration) - Upgrading from v3.x to v4.0

### Development Resources
- [GitHub Actions Workflows](.github/workflows/README.md) - CI/CD and automation
- [Documentation Development](docs/README.md) - Contributing to docs
- [Deployment Scripts](scripts/README.md) - Local development tools

## 🚀 Development & Deployment

### Local Development

```bash
# Setup documentation development
./scripts/deploy-docs.sh dev

# Validate package before publishing
./scripts/publish-package.sh validate

# Run comprehensive tests
./scripts/publish-package.sh test
```

### Publishing

```bash
# Create a new release
./scripts/publish-package.sh release --version 1.0.0

# Publish to pub.dev (manual)
./scripts/publish-package.sh publish
```

### Automated Workflows

This project includes comprehensive GitHub Actions workflows:

- **CI/CD Pipeline** - Automated testing, validation, and quality checks
- **Documentation Deployment** - Automatic GitHub Pages updates
- **Package Publishing** - Automated pub.dev releases
- **Release Management** - Version bumping and changelog generation

See [GitHub Actions Documentation](.github/workflows/README.md) for details.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting PRs.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/flutter_wallet_card.git`
3. Install dependencies: `flutter pub get`
4. Run tests: `flutter test`
5. Start documentation server: `./scripts/deploy-docs.sh dev`

### Before Submitting

- Run `./scripts/publish-package.sh validate` to ensure quality
- Update documentation if needed
- Add tests for new features
- Follow existing code style

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: [support@example.com](mailto:support@example.com)
- 🐛 Issues: [GitHub Issues](https://github.com/WebEferen/flutter_wallet_card/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/WebEferen/flutter_wallet_card/discussions)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

---

**Made with ❤️ for the Flutter community**
