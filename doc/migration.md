---
layout: default
title: Migration Guide
---

# Migration Guide

Guide for migrating from Flutter Wallet Card v3.x to v4.0.

## Overview

Version 4.0 introduces a unified API that works across both iOS and Android platforms, replacing the separate platform-specific methods from v3.x. This guide will help you update your existing code to use the new API.

## Breaking Changes

### 1. Unified API

**v3.x (Old):**
```dart
// Platform-specific methods
if (Platform.isIOS) {
  await FlutterWalletCard.addPasskit(passkitData);
} else if (Platform.isAndroid) {
  await FlutterWalletCard.addGoogleWallet(googleWalletData);
}
```

**v4.0 (New):**
```dart
// Unified method for both platforms
final card = WalletCard(/* ... */);
await FlutterWalletCard.addToWallet(card);
```

### 2. New Model Structure

**v3.x (Old):**
```dart
// Separate models for each platform
final passkitPass = PasskitPass(
  description: 'Store Card',
  organizationName: 'My Store',
  passTypeIdentifier: 'pass.com.example.store',
  serialNumber: '001',
  teamIdentifier: 'ABC123',
  // ... other properties
);
```

**v4.0 (New):**
```dart
// Unified WalletCard model
final card = WalletCard(
  id: 'store-card-001',
  type: WalletCardType.storeCard,
  platformData: {
    'passTypeIdentifier': 'pass.com.example.store',
    'teamIdentifier': 'ABC123',
    'formatVersion': 1,
  },
  metadata: WalletCardMetadata(
    title: 'Store Card',
    organizationName: 'My Store',
    serialNumber: '001',
  ),
);
```

### 3. Method Name Changes

| v3.x Method | v4.0 Method | Notes |
|-------------|-------------|---------|
| `addPasskit()` | `addToWallet()` | Unified method |
| `addGoogleWallet()` | `addToWallet()` | Unified method |
| `isPasskitAvailable()` | `isWalletAvailable` | Now a getter |
| `isGoogleWalletAvailable()` | `isWalletAvailable` | Now a getter |
| `viewPassInWallet()` | `viewInWallet()` | Simplified name |
| `isPassAdded()` | `isCardAdded()` | Consistent naming |

### 4. Exception Handling

**v3.x (Old):**
```dart
try {
  await FlutterWalletCard.addPasskit(pass);
} catch (e) {
  // Generic exception handling
  print('Error: $e');
}
```

**v4.0 (New):**
```dart
try {
  await FlutterWalletCard.addToWallet(card);
} on WalletException catch (e) {
  // Specific wallet exception with error codes
  switch (e.code) {
    case 'PLATFORM_NOT_SUPPORTED':
      print('Platform not supported');
      break;
    case 'WALLET_NOT_AVAILABLE':
      print('Wallet not available');
      break;
    default:
      print('Wallet error: ${e.message}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

## Step-by-Step Migration

### Step 1: Update Dependencies

Update your `pubspec.yaml`:

```yaml
dependencies:
  flutter_wallet_card: ^4.0.0  # Update to v4.0
```

Run:
```bash
flutter pub get
```

### Step 2: Update Imports

**v3.x (Old):**
```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';
import 'package:flutter_wallet_card/models/PasskitField.dart';
// ... other old model imports
```

**v4.0 (New):**
```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';
```

### Step 3: Replace Platform-Specific Code

#### iOS Migration Example

**v3.x (Old):**
```dart
final passkitPass = PasskitPass(
  description: 'Loyalty Card',
  formatVersion: 1,
  organizationName: 'My Store',
  passTypeIdentifier: 'pass.com.example.loyalty',
  serialNumber: '12345',
  teamIdentifier: 'ABC123DEF4',
  logoText: 'MY STORE',
  foregroundColor: Color.fromRGBO(255, 255, 255, 1),
  backgroundColor: Color.fromRGBO(76, 175, 80, 1),
  labelColor: Color.fromRGBO(255, 255, 255, 1),
  generic: PasskitStructure(
    primaryFields: [
      PasskitField(
        key: 'points',
        label: 'Points',
        value: '2500',
      ),
    ],
    secondaryFields: [
      PasskitField(
        key: 'member',
        label: 'Member',
        value: 'John Doe',
      ),
    ],
  ),
);

if (Platform.isIOS) {
  await FlutterWalletCard.addPasskit(passkitPass);
}
```

**v4.0 (New):**
```dart
final card = WalletCard(
  id: 'loyalty-12345',
  type: WalletCardType.storeCard,
  platformData: {
    'passTypeIdentifier': 'pass.com.example.loyalty',
    'teamIdentifier': 'ABC123DEF4',
    'formatVersion': 1,
  },
  metadata: WalletCardMetadata(
    title: 'Loyalty Card',
    description: 'My Store Loyalty Card',
    organizationName: 'My Store',
    serialNumber: '12345',
    customFields: {
      'points': '2500',
      'member': 'John Doe',
    },
  ),
  visuals: WalletCardVisuals(
    backgroundColor: Color(0xFF4CAF50),
    foregroundColor: Color(0xFFFFFFFF),
    labelColor: Color(0xFFFFFFFF),
    logoText: 'MY STORE',
  ),
);

// Works on both iOS and Android
await FlutterWalletCard.addToWallet(card);
```

#### Android Migration Example

**v3.x (Old):**
```dart
final googleWalletData = {
  'issuerId': 'your_issuer_id',
  'classId': 'your_class_id',
  'objectId': 'loyalty_object_001',
  'title': 'Loyalty Card',
  'subtitle': 'My Store',
  'description': 'Store loyalty program',
};

if (Platform.isAndroid) {
  await FlutterWalletCard.addGoogleWallet(googleWalletData);
}
```

**v4.0 (New):**
```dart
final card = WalletCard(
  id: 'loyalty_object_001',
  type: WalletCardType.storeCard,
  platformData: {
    'issuerId': 'your_issuer_id',
    'classId': 'your_class_id',
  },
  metadata: WalletCardMetadata(
    title: 'Loyalty Card',
    subtitle: 'My Store',
    description: 'Store loyalty program',
    organizationName: 'My Store',
    serialNumber: 'loyalty_object_001',
  ),
);

// Works on both iOS and Android
await FlutterWalletCard.addToWallet(card);
```

### Step 4: Update Availability Checks

**v3.x (Old):**
```dart
bool isAvailable = false;
if (Platform.isIOS) {
  isAvailable = await FlutterWalletCard.isPasskitAvailable();
} else if (Platform.isAndroid) {
  isAvailable = await FlutterWalletCard.isGoogleWalletAvailable();
}
```

**v4.0 (New):**
```dart
// Unified availability check
bool isAvailable = await FlutterWalletCard.isWalletAvailable;
```

### Step 5: Update Card Status Checks

**v3.x (Old):**
```dart
bool isAdded = false;
if (Platform.isIOS) {
  isAdded = await FlutterWalletCard.isPassAdded('pass_id');
} else if (Platform.isAndroid) {
  // Android-specific check
  isAdded = await FlutterWalletCard.isGoogleWalletCardAdded('card_id');
}
```

**v4.0 (New):**
```dart
// Unified card status check
bool isAdded = await FlutterWalletCard.isCardAdded('card_id');
```

### Step 6: Update File Operations

**v3.x (Old):**
```dart
// File operations were platform-specific
if (Platform.isIOS) {
  final passkit = await Passkit().saveFromPath(id: 'example', file: file);
  await FlutterWalletCard.addPasskit(passkit);
}
```

**v4.0 (New):**
```dart
// Unified file operations
await FlutterWalletCard.addFromFile(file);
// or
await FlutterWalletCard.addFromUrl('https://example.com/card.pkpass');
```

## Migration Helpers

### Cross-Platform Card Factory

Create a helper class to ease migration:

```dart
class MigrationHelper {
  /// Converts old PasskitPass to new WalletCard
  static WalletCard fromPasskitPass(PasskitPass oldPass) {
    return WalletCard(
      id: oldPass.serialNumber,
      type: WalletCardType.generic,
      platformData: {
        'passTypeIdentifier': oldPass.passTypeIdentifier,
        'teamIdentifier': oldPass.teamIdentifier,
        'formatVersion': oldPass.formatVersion,
      },
      metadata: WalletCardMetadata(
        title: oldPass.description,
        organizationName: oldPass.organizationName,
        serialNumber: oldPass.serialNumber,
      ),
      visuals: WalletCardVisuals(
        backgroundColor: oldPass.backgroundColor,
        foregroundColor: oldPass.foregroundColor,
        labelColor: oldPass.labelColor,
        logoText: oldPass.logoText,
      ),
    );
  }

  /// Creates platform-appropriate card data
  static WalletCard createUnifiedCard({
    required String id,
    required String title,
    required String organizationName,
    required String serialNumber,
    WalletCardType type = WalletCardType.generic,
    Color? backgroundColor,
    String? logoText,
  }) {
    Map<String, dynamic> platformData;
    
    if (Platform.isIOS) {
      platformData = {
        'passTypeIdentifier': 'pass.com.example.generic',
        'teamIdentifier': 'YOUR_TEAM_ID',
        'formatVersion': 1,
      };
    } else if (Platform.isAndroid) {
      platformData = {
        'issuerId': 'YOUR_ISSUER_ID',
        'classId': 'YOUR_CLASS_ID',
      };
    } else {
      throw UnsupportedError('Platform not supported');
    }

    return WalletCard(
      id: id,
      type: type,
      platformData: platformData,
      metadata: WalletCardMetadata(
        title: title,
        organizationName: organizationName,
        serialNumber: serialNumber,
      ),
      visuals: backgroundColor != null || logoText != null
        ? WalletCardVisuals(
            backgroundColor: backgroundColor,
            logoText: logoText,
          )
        : null,
    );
  }
}
```

### Gradual Migration Strategy

If you need to migrate gradually, you can use version checks:

```dart
class WalletService {
  static Future<void> addCard(dynamic cardData) async {
    if (cardData is WalletCard) {
      // v4.0 code path
      await FlutterWalletCard.addToWallet(cardData);
    } else if (cardData is PasskitPass) {
      // Migration path: convert old model to new
      final newCard = MigrationHelper.fromPasskitPass(cardData);
      await FlutterWalletCard.addToWallet(newCard);
    } else {
      throw ArgumentError('Unsupported card data type');
    }
  }
}
```

## Common Migration Issues

### Issue 1: Missing Required Fields

**Problem:**
```dart
// This will cause an error in v4.0
final card = WalletCard(
  id: 'card-001',
  type: WalletCardType.storeCard,
  platformData: {},
  metadata: WalletCardMetadata(
    title: 'Card',
    // Missing required fields!
  ),
);
```

**Solution:**
```dart
final card = WalletCard(
  id: 'card-001',
  type: WalletCardType.storeCard,
  platformData: {
    'passTypeIdentifier': 'pass.com.example.store',
    'teamIdentifier': 'ABC123',
    'formatVersion': 1,
  },
  metadata: WalletCardMetadata(
    title: 'Card',
    organizationName: 'Required!', // Add required field
    serialNumber: 'Required!',     // Add required field
  ),
);
```

### Issue 2: Color Format Changes

**Problem:**
```dart
// v3.x color format
foregroundColor: Color.fromRGBO(255, 255, 255, 1),
```

**Solution:**
```dart
// v4.0 color format (both work, but hex is preferred)
foregroundColor: Color(0xFFFFFFFF),
// or
foregroundColor: Color.fromRGBO(255, 255, 255, 1),
```

### Issue 3: Platform Data Structure

**Problem:**
```dart
// Mixing platform data
platformData: {
  'passTypeIdentifier': 'pass.com.example', // iOS
  'issuerId': 'issuer_id',                   // Android
}
```

**Solution:**
```dart
// Use platform-specific data
Map<String, dynamic> platformData;
if (Platform.isIOS) {
  platformData = {
    'passTypeIdentifier': 'pass.com.example',
    'teamIdentifier': 'ABC123',
    'formatVersion': 1,
  };
} else {
  platformData = {
    'issuerId': 'issuer_id',
    'classId': 'class_id',
  };
}
```

## Testing Your Migration

### Unit Tests

```dart
void main() {
  group('Migration Tests', () {
    test('should create valid WalletCard from old data', () {
      final card = WalletCard(
        id: 'test-001',
        type: WalletCardType.storeCard,
        platformData: {
          'passTypeIdentifier': 'pass.com.test',
          'teamIdentifier': 'TEST123',
          'formatVersion': 1,
        },
        metadata: WalletCardMetadata(
          title: 'Test Card',
          organizationName: 'Test Org',
          serialNumber: 'test-001',
        ),
      );

      expect(card.id, 'test-001');
      expect(card.type, WalletCardType.storeCard);
      expect(card.metadata.title, 'Test Card');
    });

    test('should handle platform-specific data correctly', () {
      // Test iOS data
      final iosCard = MigrationHelper.createUnifiedCard(
        id: 'ios-001',
        title: 'iOS Card',
        organizationName: 'Test',
        serialNumber: '001',
      );

      expect(iosCard.platformData.containsKey('passTypeIdentifier'), true);
    });
  });
}
```

### Integration Tests

```dart
void main() {
  group('Wallet Integration Tests', () {
    testWidgets('should add card to wallet', (WidgetTester tester) async {
      final card = WalletCard(
        id: 'integration-test-001',
        type: WalletCardType.generic,
        platformData: {
          'passTypeIdentifier': 'pass.com.test',
          'teamIdentifier': 'TEST123',
          'formatVersion': 1,
        },
        metadata: WalletCardMetadata(
          title: 'Integration Test Card',
          organizationName: 'Test Org',
          serialNumber: 'integration-test-001',
        ),
      );

      // This should not throw an exception
      expect(() async => await FlutterWalletCard.addToWallet(card), 
             returnsNormally);
    });
  });
}
```

## Post-Migration Checklist

- [ ] Updated all imports to use new models
- [ ] Replaced platform-specific methods with unified API
- [ ] Updated exception handling to use `WalletException`
- [ ] Converted old model structures to `WalletCard`
- [ ] Updated availability checks to use unified getter
- [ ] Tested on both iOS and Android devices
- [ ] Updated documentation and comments
- [ ] Removed old v3.x dependencies and imports
- [ ] Verified all wallet operations work correctly
- [ ] Updated error handling and user feedback

## Getting Help

If you encounter issues during migration:

1. Check the [API Reference](api-reference.html) for detailed method documentation
2. Review the [Examples](examples.html) for common use cases
3. Search [GitHub Issues](https://github.com/WebEferen/flutter_wallet_card/issues) for similar problems
4. Create a new issue if you find a bug or need help

The v4.0 API is designed to be more consistent and easier to use across platforms. While migration requires some effort, the unified API will make your code simpler and more maintainable in the long run.