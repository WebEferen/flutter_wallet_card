---
layout: default
title: API Reference
---

# API Reference

Complete API documentation for Flutter Wallet Card v4.0.

## FlutterWalletCard

The main class providing wallet functionality.

### Static Properties

#### `isWalletAvailable`

```dart
static Future<bool> get isWalletAvailable
```

Checks if wallet functionality is available on the current device.

**Returns:** `Future<bool>` - `true` if wallet is available, `false` otherwise.

**Throws:** `WalletException` if the platform is not supported.

**Example:**
```dart
bool available = await FlutterWalletCard.isWalletAvailable;
```

### Static Methods

#### `addToWallet`

```dart
static Future<void> addToWallet(WalletCard card)
```

Adds a wallet card to the device's wallet.

**Parameters:**
- `card` (`WalletCard`) - The wallet card to add

**Returns:** `Future<void>`

**Throws:** `WalletException` if the operation fails.

**Example:**
```dart
final card = WalletCard(/* ... */);
await FlutterWalletCard.addToWallet(card);
```

#### `isCardAdded`

```dart
static Future<bool> isCardAdded(String cardId)
```

Checks if a specific card is already added to the wallet.

**Parameters:**
- `cardId` (`String`) - The unique identifier of the card

**Returns:** `Future<bool>` - `true` if card is added, `false` otherwise.

**Throws:** `WalletException` if the operation fails.

**Example:**
```dart
bool isAdded = await FlutterWalletCard.isCardAdded('my-card-001');
```

#### `viewInWallet`

```dart
static Future<void> viewInWallet(String cardId)
```

Opens the wallet app and displays the specified card.

**Parameters:**
- `cardId` (`String`) - The unique identifier of the card

**Returns:** `Future<void>`

**Throws:** `WalletException` if the operation fails.

**Example:**
```dart
await FlutterWalletCard.viewInWallet('my-card-001');
```

#### `addFromFile`

```dart
static Future<void> addFromFile(File file)
```

Adds a wallet card from a file (.pkpass for iOS, .json for Android).

**Parameters:**
- `file` (`File`) - The wallet card file

**Returns:** `Future<void>`

**Throws:** `WalletException` if the operation fails.

**Example:**
```dart
final file = File('path/to/card.pkpass');
await FlutterWalletCard.addFromFile(file);
```

#### `addFromUrl`

```dart
static Future<void> addFromUrl(String url)
```

Downloads and adds a wallet card from a URL.

**Parameters:**
- `url` (`String`) - The URL of the wallet card file

**Returns:** `Future<void>`

**Throws:** `WalletException` if the operation fails.

**Example:**
```dart
await FlutterWalletCard.addFromUrl('https://example.com/card.pkpass');
```

#### `generateCardFile`

```dart
static Future<File> generateCardFile(WalletCard card, {String? outputPath})
```

Generates a platform-specific wallet card file.

**Parameters:**
- `card` (`WalletCard`) - The wallet card to generate
- `outputPath` (`String?`) - Optional output path for the file

**Returns:** `Future<File>` - The generated wallet card file.

**Throws:** `WalletException` if the operation fails.

**Example:**
```dart
final card = WalletCard(/* ... */);
final file = await FlutterWalletCard.generateCardFile(card);
```

## Models

### WalletCard

The main model representing a wallet card.

```dart
class WalletCard {
  final String id;
  final WalletCardType type;
  final Map<String, dynamic> platformData;
  final WalletCardMetadata metadata;
  final WalletCardVisuals? visuals;
  final File? file;
}
```

**Properties:**
- `id` (`String`) - Unique identifier for the card
- `type` (`WalletCardType`) - Type of the wallet card
- `platformData` (`Map<String, dynamic>`) - Platform-specific data
- `metadata` (`WalletCardMetadata`) - Card metadata
- `visuals` (`WalletCardVisuals?`) - Visual styling (optional)
- `file` (`File?`) - Associated file (optional)

**Example:**
```dart
final card = WalletCard(
  id: 'loyalty-001',
  type: WalletCardType.storeCard,
  platformData: {
    'passTypeIdentifier': 'pass.com.example.loyalty',
    'teamIdentifier': 'ABC123DEF4',
  },
  metadata: WalletCardMetadata(
    title: 'Loyalty Card',
    organizationName: 'Example Store',
    serialNumber: '001',
  ),
);
```

### WalletCardType

Enum representing different types of wallet cards.

```dart
enum WalletCardType {
  boardingPass,
  coupon,
  eventTicket,
  generic,
  storeCard,
  loyalty,
}
```

### WalletCardMetadata

Metadata information for a wallet card.

```dart
class WalletCardMetadata {
  final String title;
  final String? subtitle;
  final String? description;
  final String organizationName;
  final String serialNumber;
  final DateTime? expirationDate;
  final DateTime? relevantDate;
  final List<WalletCardLocation>? locations;
  final Map<String, String>? customFields;
}
```

**Required Properties:**
- `title` (`String`) - Card title
- `organizationName` (`String`) - Organization name
- `serialNumber` (`String`) - Unique serial number

**Optional Properties:**
- `subtitle` (`String?`) - Card subtitle
- `description` (`String?`) - Card description
- `expirationDate` (`DateTime?`) - Expiration date
- `relevantDate` (`DateTime?`) - Relevant date for notifications
- `locations` (`List<WalletCardLocation>?`) - Relevant locations
- `customFields` (`Map<String, String>?`) - Custom key-value pairs

### WalletCardVisuals

Visual styling for a wallet card.

```dart
class WalletCardVisuals {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? labelColor;
  final String? logoText;
  final Map<String, String>? images;
}
```

**Properties:**
- `backgroundColor` (`Color?`) - Background color
- `foregroundColor` (`Color?`) - Foreground/text color
- `labelColor` (`Color?`) - Label color
- `logoText` (`String?`) - Logo text
- `images` (`Map<String, String>?`) - Image paths by type

**Example:**
```dart
final visuals = WalletCardVisuals(
  backgroundColor: Color(0xFF1976D2),
  foregroundColor: Color(0xFFFFFFFF),
  logoText: 'My Store',
);
```

### WalletCardLocation

Location information for wallet cards.

```dart
class WalletCardLocation {
  final double latitude;
  final double longitude;
  final double? altitude;
  final String? relevantText;
}
```

## Exceptions

### WalletException

Custom exception thrown by wallet operations.

```dart
class WalletException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
}
```

**Properties:**
- `message` (`String`) - Error message
- `code` (`String?`) - Error code (optional)
- `details` (`dynamic`) - Additional error details (optional)

**Common Error Codes:**
- `PLATFORM_NOT_SUPPORTED` - Platform doesn't support wallet operations
- `WALLET_NOT_AVAILABLE` - Wallet app is not available
- `INVALID_CARD_DATA` - Card data is invalid
- `NETWORK_ERROR` - Network operation failed
- `FILE_ERROR` - File operation failed

## Platform-Specific Data

### iOS (Apple Wallet)

Required platform data for iOS:

```dart
platformData: {
  'passTypeIdentifier': 'pass.com.yourcompany.yourapp',
  'teamIdentifier': 'YOUR_TEAM_ID',
  'formatVersion': 1,
}
```

### Android (Google Wallet)

Required platform data for Android:

```dart
platformData: {
  'issuerId': 'YOUR_ISSUER_ID',
  'classId': 'YOUR_CLASS_ID',
}
```

## Usage Examples

### Basic Store Card

```dart
final storeCard = WalletCard(
  id: 'store-card-001',
  type: WalletCardType.storeCard,
  platformData: {
    'passTypeIdentifier': 'pass.com.example.store',
    'teamIdentifier': 'ABC123DEF4',
    'formatVersion': 1,
  },
  metadata: WalletCardMetadata(
    title: 'Store Loyalty Card',
    description: 'Earn points with every purchase',
    organizationName: 'Example Store',
    serialNumber: '12345',
  ),
  visuals: WalletCardVisuals(
    backgroundColor: Color(0xFF4CAF50),
    foregroundColor: Color(0xFFFFFFFF),
    logoText: 'Example Store',
  ),
);

await FlutterWalletCard.addToWallet(storeCard);
```

### Event Ticket

```dart
final eventTicket = WalletCard(
  id: 'event-ticket-001',
  type: WalletCardType.eventTicket,
  platformData: {
    'passTypeIdentifier': 'pass.com.example.event',
    'teamIdentifier': 'ABC123DEF4',
    'formatVersion': 1,
  },
  metadata: WalletCardMetadata(
    title: 'Concert Ticket',
    subtitle: 'Rock Band Live',
    description: 'VIP Access',
    organizationName: 'Event Organizer',
    serialNumber: 'TKT-001',
    relevantDate: DateTime(2024, 6, 15, 20, 0),
    locations: [
      WalletCardLocation(
        latitude: 37.7749,
        longitude: -122.4194,
        relevantText: 'Concert Hall',
      ),
    ],
  ),
  visuals: WalletCardVisuals(
    backgroundColor: Color(0xFF9C27B0),
    foregroundColor: Color(0xFFFFFFFF),
    logoText: 'Concert',
  ),
);

await FlutterWalletCard.addToWallet(eventTicket);
```

## Error Handling

```dart
try {
  await FlutterWalletCard.addToWallet(card);
  print('Card added successfully');
} on WalletException catch (e) {
  switch (e.code) {
    case 'PLATFORM_NOT_SUPPORTED':
      print('Wallet not supported on this platform');
      break;
    case 'WALLET_NOT_AVAILABLE':
      print('Wallet app not available');
      break;
    case 'INVALID_CARD_DATA':
      print('Invalid card data: ${e.message}');
      break;
    default:
      print('Wallet error: ${e.message}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```