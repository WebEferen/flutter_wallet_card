import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/models/wallet_card.dart';
import 'dart:io';
import 'dart:ui';

void main() {
  group('WalletCardType', () {
    test('should have correct values', () {
      expect(WalletCardType.boardingPass.name, 'boardingPass');
      expect(WalletCardType.coupon.name, 'coupon');
      expect(WalletCardType.eventTicket.name, 'eventTicket');
      expect(WalletCardType.generic.name, 'generic');
      expect(WalletCardType.storeCard.name, 'storeCard');
    });
  });

  group('WalletCardMetadata', () {
    test('should create from JSON', () {
      final json = {
        'title': 'Test Card',
        'description': 'Test Description',
        'organizationName': 'Test Org',
        'serialNumber': '12345',
      };

      final metadata = WalletCardMetadata.fromJson(json);

      expect(metadata.title, 'Test Card');
      expect(metadata.description, 'Test Description');
      expect(metadata.organizationName, 'Test Org');
      expect(metadata.serialNumber, '12345');
    });

    test('should convert to JSON', () {
      final metadata = WalletCardMetadata(
        title: 'Test Card',
        description: 'Test Description',
        organizationName: 'Test Org',
        serialNumber: '12345',
      );

      final json = metadata.toJson();

      expect(json['title'], 'Test Card');
      expect(json['description'], 'Test Description');
      expect(json['organizationName'], 'Test Org');
      expect(json['serialNumber'], '12345');
    });
  });

  group('WalletCardVisuals', () {
    test('should create from JSON', () {
      final json = {
        'backgroundColor': '#FFFFFF',
        'foregroundColor': '#000000',
        'labelColor': '#666666',
      };

      final visuals = WalletCardVisuals.fromJson(json);

      expect(visuals.backgroundColor, const Color(0xFFFFFFFF));
      expect(visuals.foregroundColor, const Color(0xFF000000));
      expect(visuals.labelColor, const Color(0xFF666666));
    });

    test('should convert to JSON', () {
      final visuals = WalletCardVisuals(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        labelColor: const Color(0xFF666666),
      );

      final json = visuals.toJson();

      expect(json['backgroundColor'], '#FFFFFF');
       expect(json['foregroundColor'], '#000000');
       expect(json['labelColor'], '#666666');
    });
  });

  group('WalletCardLocation', () {
    test('should create from JSON', () {
      final json = {
        'latitude': 37.7749,
        'longitude': -122.4194,
        'altitude': 100.0,
        'relevantText': 'Near location',
      };

      final location = WalletCardLocation.fromJson(json);

      expect(location.latitude, 37.7749);
      expect(location.longitude, -122.4194);
      expect(location.altitude, 100.0);
      expect(location.relevantText, 'Near location');
    });

    test('should convert to JSON', () {
      final location = WalletCardLocation(
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 100.0,
        relevantText: 'Near location',
      );

      final json = location.toJson();

      expect(json['latitude'], 37.7749);
      expect(json['longitude'], -122.4194);
      expect(json['altitude'], 100.0);
      expect(json['relevantText'], 'Near location');
    });
  });

  group('WalletCard', () {
    test('should create from JSON', () {
      final json = {
        'id': 'test-id',
        'type': 'generic',
        'platformData': {'key': 'value'},
        'metadata': {
          'title': 'Test Card',
          'description': 'Test Description',
          'organizationName': 'Test Org',
          'serialNumber': '12345',
        },
        'visuals': {
          'backgroundColor': '#FFFFFF',
          'foregroundColor': '#000000',
        },
      };

      final card = WalletCard.fromJson(json);

      expect(card.id, 'test-id');
      expect(card.type, WalletCardType.generic);
      expect(card.platformData['key'], 'value');
      expect(card.metadata.title, 'Test Card');
      expect(card.visuals?.backgroundColor, const Color(0xFFFFFFFF));
    });

    test('should convert to JSON', () {
      final card = WalletCard(
        id: 'test-id',
        type: WalletCardType.generic,
        platformData: {'key': 'value'},
        metadata: WalletCardMetadata(
          title: 'Test Card',
          description: 'Test Description',
          organizationName: 'Test Org',
          serialNumber: '12345',
        ),
        visuals: WalletCardVisuals(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF000000),
        ),
      );

      final json = card.toJson();

      expect(json['id'], 'test-id');
      expect(json['type'], 'generic');
      expect(json['platformData']['key'], 'value');
      expect(json['metadata'].title, 'Test Card');
      expect(json['visuals'].backgroundColor, const Color(0xFFFFFFFF));
    });

    test('should handle file property', () {
      final file = File('/test/path');
      final card = WalletCard(
        id: 'test-id',
        type: WalletCardType.generic,
        platformData: {},
        metadata: WalletCardMetadata(
          title: 'Test Card',
          description: 'Test Description',
          organizationName: 'Test Org',
          serialNumber: '12345',
        ),
        visuals: WalletCardVisuals(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF000000),
        ),
        file: file,
      );

      expect(card.file, file);
      expect(card.file?.path, '/test/path');
    });

    test('should handle locations', () {
      final location = WalletCardLocation(
        latitude: 37.7749,
        longitude: -122.4194,
      );

      final card = WalletCard(
        id: 'test-id',
        type: WalletCardType.generic,
        platformData: {},
        metadata: WalletCardMetadata(
          title: 'Test Card',
          description: 'Test Description',
          organizationName: 'Test Org',
          serialNumber: '12345',
          locations: [location],
        ),
        visuals: WalletCardVisuals(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF000000),
        ),
      );

      expect(card.metadata.locations?.length, 1);
      expect(card.metadata.locations?.first.latitude, 37.7749);
    });
  });
}