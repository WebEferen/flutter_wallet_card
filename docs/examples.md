---
layout: default
title: Examples
---

# Examples

Practical examples of using Flutter Wallet Card in different scenarios.

## Basic Examples

### Simple Store Card

```dart
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';

Future<void> createStoreCard() async {
  final card = WalletCard(
    id: 'store-loyalty-001',
    type: WalletCardType.storeCard,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.store',
      'teamIdentifier': 'ABC123DEF4',
      'formatVersion': 1,
    },
    metadata: WalletCardMetadata(
      title: 'Loyalty Card',
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

  try {
    await FlutterWalletCard.addToWallet(card);
    print('Store card added successfully!');
  } catch (e) {
    print('Failed to add store card: $e');
  }
}
```

### Event Ticket

```dart
Future<void> createEventTicket() async {
  final card = WalletCard(
    id: 'concert-ticket-001',
    type: WalletCardType.eventTicket,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.events',
      'teamIdentifier': 'ABC123DEF4',
      'formatVersion': 1,
    },
    metadata: WalletCardMetadata(
      title: 'Rock Concert',
      subtitle: 'The Amazing Band',
      description: 'VIP Access - Front Row',
      organizationName: 'Concert Venue',
      serialNumber: 'TKT-VIP-001',
      relevantDate: DateTime(2024, 8, 15, 20, 0), // Concert date
      locations: [
        WalletCardLocation(
          latitude: 37.7749,
          longitude: -122.4194,
          relevantText: 'Madison Square Garden',
        ),
      ],
      customFields: {
        'seat': 'A1',
        'section': 'VIP',
        'gate': 'B',
      },
    ),
    visuals: WalletCardVisuals(
      backgroundColor: Color(0xFF9C27B0),
      foregroundColor: Color(0xFFFFFFFF),
      logoText: 'CONCERT',
    ),
  );

  await FlutterWalletCard.addToWallet(card);
}
```

### Boarding Pass

```dart
Future<void> createBoardingPass() async {
  final card = WalletCard(
    id: 'flight-bp-001',
    type: WalletCardType.boardingPass,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.airline',
      'teamIdentifier': 'ABC123DEF4',
      'formatVersion': 1,
    },
    metadata: WalletCardMetadata(
      title: 'Flight AA123',
      subtitle: 'New York → Los Angeles',
      description: 'Economy Class',
      organizationName: 'Example Airlines',
      serialNumber: 'BP-AA123-001',
      relevantDate: DateTime(2024, 7, 20, 14, 30), // Departure time
      locations: [
        WalletCardLocation(
          latitude: 40.6413,
          longitude: -73.7781,
          relevantText: 'JFK Airport - Terminal 4',
        ),
      ],
      customFields: {
        'passenger': 'John Doe',
        'seat': '12A',
        'gate': 'B7',
        'boarding': 'Group 2',
      },
    ),
    visuals: WalletCardVisuals(
      backgroundColor: Color(0xFF2196F3),
      foregroundColor: Color(0xFFFFFFFF),
      logoText: 'AIRLINE',
    ),
  );

  await FlutterWalletCard.addToWallet(card);
}
```

## Advanced Examples

### Dynamic Card with User Data

```dart
class UserCard {
  final String userId;
  final String userName;
  final int loyaltyPoints;
  final String membershipLevel;

  UserCard({
    required this.userId,
    required this.userName,
    required this.loyaltyPoints,
    required this.membershipLevel,
  });
}

Future<void> createDynamicLoyaltyCard(UserCard user) async {
  // Determine card color based on membership level
  Color cardColor;
  switch (user.membershipLevel.toLowerCase()) {
    case 'gold':
      cardColor = Color(0xFFFFD700);
      break;
    case 'silver':
      cardColor = Color(0xFFC0C0C0);
      break;
    case 'platinum':
      cardColor = Color(0xFFE5E4E2);
      break;
    default:
      cardColor = Color(0xFF4CAF50);
  }

  final card = WalletCard(
    id: 'loyalty-${user.userId}',
    type: WalletCardType.storeCard,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.loyalty',
      'teamIdentifier': 'ABC123DEF4',
      'formatVersion': 1,
    },
    metadata: WalletCardMetadata(
      title: '${user.membershipLevel} Member',
      subtitle: user.userName,
      description: '${user.loyaltyPoints} points available',
      organizationName: 'Premium Store',
      serialNumber: user.userId,
      customFields: {
        'member_name': user.userName,
        'points': user.loyaltyPoints.toString(),
        'level': user.membershipLevel,
        'member_since': '2023',
      },
    ),
    visuals: WalletCardVisuals(
      backgroundColor: cardColor,
      foregroundColor: Color(0xFF000000),
      logoText: 'PREMIUM',
    ),
  );

  await FlutterWalletCard.addToWallet(card);
}

// Usage
final user = UserCard(
  userId: 'USER123',
  userName: 'John Doe',
  loyaltyPoints: 2500,
  membershipLevel: 'Gold',
);

await createDynamicLoyaltyCard(user);
```

### Card with Expiration and Location

```dart
Future<void> createCouponCard() async {
  final expirationDate = DateTime.now().add(Duration(days: 30));
  
  final card = WalletCard(
    id: 'coupon-summer-001',
    type: WalletCardType.coupon,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.coupons',
      'teamIdentifier': 'ABC123DEF4',
      'formatVersion': 1,
    },
    metadata: WalletCardMetadata(
      title: '20% OFF',
      subtitle: 'Summer Sale',
      description: 'Valid on all summer items',
      organizationName: 'Fashion Store',
      serialNumber: 'COUPON-SUMMER-001',
      expirationDate: expirationDate,
      locations: [
        WalletCardLocation(
          latitude: 37.7749,
          longitude: -122.4194,
          relevantText: 'Downtown Store',
        ),
        WalletCardLocation(
          latitude: 37.7849,
          longitude: -122.4094,
          relevantText: 'Mall Location',
        ),
      ],
      customFields: {
        'discount': '20%',
        'category': 'Summer Items',
        'min_purchase': '\$50',
        'code': 'SUMMER20',
      },
    ),
    visuals: WalletCardVisuals(
      backgroundColor: Color(0xFFFF9800),
      foregroundColor: Color(0xFFFFFFFF),
      logoText: 'SALE',
    ),
  );

  await FlutterWalletCard.addToWallet(card);
}
```

### Multi-Platform Card Factory

```dart
class WalletCardFactory {
  static WalletCard createLoyaltyCard({
    required String userId,
    required String userName,
    required int points,
  }) {
    // Platform-specific configuration
    Map<String, dynamic> platformData;
    
    if (Platform.isIOS) {
      platformData = {
        'passTypeIdentifier': 'pass.com.example.loyalty',
        'teamIdentifier': 'ABC123DEF4',
        'formatVersion': 1,
      };
    } else if (Platform.isAndroid) {
      platformData = {
        'issuerId': 'example_issuer_id',
        'classId': 'loyalty_class_id',
      };
    } else {
      throw UnsupportedError('Platform not supported');
    }

    return WalletCard(
      id: 'loyalty-$userId',
      type: WalletCardType.storeCard,
      platformData: platformData,
      metadata: WalletCardMetadata(
        title: 'Loyalty Card',
        subtitle: userName,
        description: '$points points available',
        organizationName: 'Universal Store',
        serialNumber: userId,
        customFields: {
          'points': points.toString(),
          'member_name': userName,
        },
      ),
      visuals: WalletCardVisuals(
        backgroundColor: Color(0xFF673AB7),
        foregroundColor: Color(0xFFFFFFFF),
        logoText: 'LOYALTY',
      ),
    );
  }

  static WalletCard createEventTicket({
    required String eventId,
    required String eventName,
    required String venue,
    required DateTime eventDate,
    required String seatInfo,
  }) {
    Map<String, dynamic> platformData;
    
    if (Platform.isIOS) {
      platformData = {
        'passTypeIdentifier': 'pass.com.example.events',
        'teamIdentifier': 'ABC123DEF4',
        'formatVersion': 1,
      };
    } else {
      platformData = {
        'issuerId': 'example_issuer_id',
        'classId': 'event_class_id',
      };
    }

    return WalletCard(
      id: 'event-$eventId',
      type: WalletCardType.eventTicket,
      platformData: platformData,
      metadata: WalletCardMetadata(
        title: eventName,
        subtitle: venue,
        description: 'Seat: $seatInfo',
        organizationName: 'Event Organizer',
        serialNumber: eventId,
        relevantDate: eventDate,
        customFields: {
          'seat': seatInfo,
          'venue': venue,
          'event_date': eventDate.toIso8601String(),
        },
      ),
      visuals: WalletCardVisuals(
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Color(0xFFFFFFFF),
        logoText: 'EVENT',
      ),
    );
  }
}

// Usage
final loyaltyCard = WalletCardFactory.createLoyaltyCard(
  userId: 'USER123',
  userName: 'Jane Doe',
  points: 1500,
);

final eventTicket = WalletCardFactory.createEventTicket(
  eventId: 'EVT001',
  eventName: 'Jazz Festival',
  venue: 'Central Park',
  eventDate: DateTime(2024, 9, 15, 19, 0),
  seatInfo: 'General Admission',
);

await FlutterWalletCard.addToWallet(loyaltyCard);
await FlutterWalletCard.addToWallet(eventTicket);
```

## File-Based Examples

### Adding Card from File

```dart
Future<void> addCardFromFile() async {
  try {
    // For iOS (.pkpass file)
    final file = File('assets/cards/loyalty_card.pkpass');
    await FlutterWalletCard.addFromFile(file);
    print('Card added from file successfully!');
  } catch (e) {
    print('Failed to add card from file: $e');
  }
}
```

### Adding Card from URL

```dart
Future<void> addCardFromUrl() async {
  const url = 'https://example.com/cards/loyalty_card.pkpass';
  
  try {
    await FlutterWalletCard.addFromUrl(url);
    print('Card added from URL successfully!');
  } catch (e) {
    print('Failed to add card from URL: $e');
  }
}
```

### Generating Card File

```dart
Future<void> generateAndSaveCard() async {
  final card = WalletCard(
    id: 'generated-card-001',
    type: WalletCardType.generic,
    platformData: {
      'passTypeIdentifier': 'pass.com.example.generic',
      'teamIdentifier': 'ABC123DEF4',
      'formatVersion': 1,
    },
    metadata: WalletCardMetadata(
      title: 'Generated Card',
      organizationName: 'Example Org',
      serialNumber: '001',
    ),
  );

  try {
    final file = await FlutterWalletCard.generateCardFile(card);
    print('Card file generated at: ${file.path}');
    
    // Optionally share the file
    // await Share.shareFiles([file.path]);
  } catch (e) {
    print('Failed to generate card file: $e');
  }
}
```

## UI Integration Examples

### Complete Flutter Widget

```dart
class WalletCardWidget extends StatefulWidget {
  @override
  _WalletCardWidgetState createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
  bool _isWalletAvailable = false;
  bool _isLoading = false;
  String? _cardId;

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
      final cardId = 'loyalty-${DateTime.now().millisecondsSinceEpoch}';
      final card = WalletCard(
        id: cardId,
        type: WalletCardType.storeCard,
        platformData: {
          'passTypeIdentifier': 'pass.com.example.loyalty',
          'teamIdentifier': 'ABC123DEF4',
          'formatVersion': 1,
        },
        metadata: WalletCardMetadata(
          title: 'Loyalty Card',
          description: 'Your store loyalty card',
          organizationName: 'Example Store',
          serialNumber: cardId,
        ),
        visuals: WalletCardVisuals(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Color(0xFFFFFFFF),
          logoText: 'STORE',
        ),
      );

      await FlutterWalletCard.addToWallet(card);
      
      setState(() {
        _cardId = cardId;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card added to wallet!')),
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

  Future<void> _viewInWallet() async {
    if (_cardId != null) {
      try {
        await FlutterWalletCard.viewInWallet(_cardId!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open wallet: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  _isWalletAvailable ? Icons.wallet : Icons.wallet_outlined,
                  color: _isWalletAvailable ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  _isWalletAvailable 
                    ? 'Wallet Available' 
                    : 'Wallet Not Available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isWalletAvailable && !_isLoading ? _addToWallet : null,
              child: _isLoading 
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Add to Wallet'),
            ),
            if (_cardId != null) ..[
              SizedBox(height: 8),
              OutlinedButton(
                onPressed: _viewInWallet,
                child: Text('View in Wallet'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Card Preview Widget

```dart
class WalletCardPreview extends StatelessWidget {
  final WalletCard card;
  final VoidCallback? onAddToWallet;

  const WalletCardPreview({
    Key? key,
    required this.card,
    this.onAddToWallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 180,
      decoration: BoxDecoration(
        color: card.visuals?.backgroundColor ?? Colors.blue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.visuals?.logoText ?? card.metadata.organizationName,
                  style: TextStyle(
                    color: card.visuals?.foregroundColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _getCardTypeIcon(card.type),
                  color: card.visuals?.foregroundColor ?? Colors.white,
                ),
              ],
            ),
            Spacer(),
            Text(
              card.metadata.title,
              style: TextStyle(
                color: card.visuals?.foregroundColor ?? Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (card.metadata.subtitle != null)
              Text(
                card.metadata.subtitle!,
                style: TextStyle(
                  color: card.visuals?.foregroundColor ?? Colors.white,
                  fontSize: 14,
                ),
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${card.metadata.serialNumber}',
                  style: TextStyle(
                    color: card.visuals?.labelColor ?? Colors.white70,
                    fontSize: 12,
                  ),
                ),
                if (onAddToWallet != null)
                  ElevatedButton(
                    onPressed: onAddToWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: card.visuals?.backgroundColor,
                      minimumSize: Size(80, 32),
                    ),
                    child: Text('Add', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCardTypeIcon(WalletCardType type) {
    switch (type) {
      case WalletCardType.storeCard:
        return Icons.store;
      case WalletCardType.eventTicket:
        return Icons.event;
      case WalletCardType.boardingPass:
        return Icons.flight;
      case WalletCardType.coupon:
        return Icons.local_offer;
      default:
        return Icons.credit_card;
    }
  }
}
```

## Error Handling Examples

### Comprehensive Error Handling

```dart
Future<void> addCardWithErrorHandling(WalletCard card) async {
  try {
    // Check if wallet is available first
    final isAvailable = await FlutterWalletCard.isWalletAvailable;
    if (!isAvailable) {
      throw WalletException('Wallet is not available on this device');
    }

    // Check if card is already added
    final isAdded = await FlutterWalletCard.isCardAdded(card.id);
    if (isAdded) {
      // Card already exists, ask user if they want to view it
      final shouldView = await _showCardExistsDialog();
      if (shouldView) {
        await FlutterWalletCard.viewInWallet(card.id);
      }
      return;
    }

    // Add the card
    await FlutterWalletCard.addToWallet(card);
    _showSuccessMessage('Card added successfully!');
    
  } on WalletException catch (e) {
    _handleWalletException(e);
  } catch (e) {
    _showErrorMessage('Unexpected error: $e');
  }
}

void _handleWalletException(WalletException e) {
  switch (e.code) {
    case 'PLATFORM_NOT_SUPPORTED':
      _showErrorMessage('Wallet is not supported on this platform');
      break;
    case 'WALLET_NOT_AVAILABLE':
      _showErrorMessage('Wallet app is not available');
      break;
    case 'INVALID_CARD_DATA':
      _showErrorMessage('Card data is invalid: ${e.message}');
      break;
    case 'NETWORK_ERROR':
      _showErrorMessage('Network error. Please check your connection.');
      break;
    default:
      _showErrorMessage('Wallet error: ${e.message}');
  }
}

Future<bool> _showCardExistsDialog() async {
  // Implementation depends on your UI framework
  // Return true if user wants to view the card
  return true;
}

void _showSuccessMessage(String message) {
  // Show success message to user
  print('Success: $message');
}

void _showErrorMessage(String message) {
  // Show error message to user
  print('Error: $message');
}
```

These examples demonstrate various use cases and patterns for integrating Flutter Wallet Card into your application. Choose the examples that best fit your specific requirements and customize them according to your app's design and functionality.