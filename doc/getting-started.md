---
layout: default
title: Getting Started
---

# Getting Started

This guide will help you integrate Flutter Wallet Card into your Flutter application.

## Prerequisites

- Flutter SDK 3.0.0 or higher
- iOS 11.0+ for Apple Wallet support
- Android API level 21+ for Google Wallet support

## Installation

### 1. Add Dependency

Add `flutter_wallet_card` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_wallet_card: ^4.0.0
```

### 2. Install Packages

```bash
flutter pub get
```

### 3. Platform Configuration

#### iOS Configuration

1. **Enable Wallet Capability**
   - Open your iOS project in Xcode
   - Select your target → Signing & Capabilities
   - Add "Wallet" capability

2. **Configure Info.plist**
   ```xml
   <key>com.apple.developer.pass-type-identifiers</key>
   <array>
       <string>pass.com.yourcompany.yourapp</string>
   </array>
   ```

#### Android Configuration

1. **Add Permissions**
   
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

2. **Minimum SDK Version**
   
   Ensure `android/app/build.gradle` has:
   ```gradle
   android {
       compileSdkVersion 33
       
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 33
       }
   }
   ```

## Basic Implementation

### 1. Import the Package

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';
```

### 2. Check Wallet Availability

```dart
Future<void> checkWalletAvailability() async {
  try {
    bool isAvailable = await FlutterWalletCard.isWalletAvailable;
    if (isAvailable) {
      print('Wallet is available on this device');
    } else {
      print('Wallet is not available');
    }
  } catch (e) {
    print('Error checking wallet availability: $e');
  }
}
```

### 3. Create a Wallet Card

```dart
WalletCard createSampleCard() {
  return WalletCard(
    id: 'sample-card-001',
    type: WalletCardType.storeCard,
    platformData: {
      'passTypeIdentifier': 'pass.com.yourcompany.yourapp',
      'teamIdentifier': 'YOUR_TEAM_ID',
      'formatVersion': 1,
    },
    metadata: WalletCardMetadata(
      title: 'Sample Store Card',
      description: 'A sample loyalty card',
      organizationName: 'Your Company',
      serialNumber: '001',
    ),
    visuals: WalletCardVisuals(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Color(0xFFFFFFFF),
      logoText: 'Your Store',
    ),
  );
}
```

### 4. Add Card to Wallet

```dart
Future<void> addCardToWallet() async {
  try {
    final card = createSampleCard();
    await FlutterWalletCard.addToWallet(card);
    print('Card added successfully!');
  } catch (e) {
    print('Failed to add card: $e');
  }
}
```

### 5. Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';

class WalletCardExample extends StatefulWidget {
  @override
  _WalletCardExampleState createState() => _WalletCardExampleState();
}

class _WalletCardExampleState extends State<WalletCardExample> {
  bool _isWalletAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWalletAvailability();
  }

  Future<void> _checkWalletAvailability() async {
    try {
      final isAvailable = await FlutterWalletCard.isWalletAvailable;
      setState(() {
        _isWalletAvailable = isAvailable;
      });
    } catch (e) {
      print('Error checking wallet availability: $e');
    }
  }

  Future<void> _addToWallet() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final card = WalletCard(
        id: 'loyalty-card-${DateTime.now().millisecondsSinceEpoch}',
        type: WalletCardType.storeCard,
        platformData: {
          'passTypeIdentifier': 'pass.com.yourcompany.loyalty',
          'teamIdentifier': 'YOUR_TEAM_ID',
          'formatVersion': 1,
        },
        metadata: WalletCardMetadata(
          title: 'Loyalty Card',
          description: 'Your loyalty rewards card',
          organizationName: 'Your Store',
          serialNumber: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        visuals: WalletCardVisuals(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Color(0xFFFFFFFF),
          logoText: 'Your Store',
        ),
      );

      await FlutterWalletCard.addToWallet(card);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card added to wallet successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add card: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Card Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isWalletAvailable ? Icons.check_circle : Icons.error,
                      color: _isWalletAvailable ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isWalletAvailable 
                        ? 'Wallet is available' 
                        : 'Wallet is not available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isWalletAvailable && !_isLoading ? _addToWallet : null,
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Add Card to Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Next Steps

- [Platform Setup](platform-setup.html) - Detailed platform configuration
- [API Reference](api-reference.html) - Complete API documentation
- [Examples](examples.html) - More usage examples
- [Migration Guide](migration.html) - Upgrading from v3.x

## Troubleshooting

### Common Issues

1. **"Wallet not available" on iOS Simulator**
   - Apple Wallet is not available in iOS Simulator
   - Test on a physical device

2. **Certificate errors on iOS**
   - Ensure your Pass Type ID is properly configured
   - Check your team identifier and certificates

3. **Permission denied on Android**
   - Verify internet permission is added
   - Check Google Wallet API configuration

For more help, check our [GitHub Issues](https://github.com/WebEferen/flutter_wallet_card/issues).