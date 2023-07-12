import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallet_card/helpers/color.dart';
import 'package:flutter_wallet_card/models/PasskitBarcode.dart';
import 'package:flutter_wallet_card/models/PasskitLocation.dart';
import 'package:flutter_wallet_card/models/PasskitStructure.dart';

class PasskitPass extends Equatable {
  /// Required. Version of the file format. The value must be 1.
  final int formatVersion;

  /// Required. Pass type identifier, as issued by Apple. The value must correspond with your signing certificate.
  final String passTypeIdentifier;

  /// Required. Brief description of the pass, used by the iOS accessibility technologies.
  /// Don’t try to include all of the data on the pass in its description,
  /// just include enough detail to distinguish passes of the same type.
  final String description;

  /// Required. Team identifier of the organization that originated and signed the pass, as issued by Apple.
  final String teamIdentifier;

  /// Required. Display name of the organization that originated and signed the pass.
  final String organizationName;

  /// Required. Serial number that uniquely identifies the pass. No two passes with the same pass type identifier may have the same serial number.
  final String serialNumber;

  /// The URL of a web service that conforms to the API described in PassKit Web Service Reference.
  /// The web service must use the HTTPS protocol; the leading https:// is included in the value of this key.
  /// On devices configured for development, there is UI in Settings to allow HTTP web services.
  final String? webServiceURL;

  /// The authentication token to use with the web service. The token must be 16 characters or longer.
  final String? authenticationToken;

  /// Optional. Information specific to the pass’s barcode.
  /// The system uses the first valid barcode dictionary in the array.
  /// Additional dictionaries can be added as fallbacks. For this dictionary’s keys,
  /// see Barcode Dictionary Keys.
  final List<PasskitBarcode>? barcodes;

  /// Optional. Background [Color] of the pass.
  final Color? backgroundColor;

  /// Optional. Foreground [Color] of the pass.
  final Color? foregroundColor;

  /// Optional. Label [Color] of the pass.
  /// If omitted, the label color is determined automatically.
  final Color? labelColor;

  /// Optional for event tickets and boarding passes; otherwise not allowed.
  /// Identifier used to group related passes. If a grouping identifier is specified,
  /// passes with the same style, pass type identifier, and grouping identifier are displayed as a group.
  /// Otherwise, passes are grouped automatically.
  /// Use this to group passes that are tightly related, such as the boarding passes for different
  /// connections of the same trip.
  final String? groupingIdentifier;

  /// Optional. Text displayed next to the logo on the pass.
  final String? logoText;

  /// Information specific to a store card.
  final PasskitStructure? storeCard;

  /// Information specific to a generic card.
  final PasskitStructure? generic;

  /// Information specific to a event ticket.
  final PasskitStructure? eventTicket;

  /// Information specific to a coupon card.
  final PasskitStructure? coupon;

  /// Information specific to a boarding pass card.
  final PasskitStructure? boardingPass;

  /// Optional. Locations where the pass is relevant. For example, the location of your store.
  final List<PasskitLocation>? locations;

  /// Optional. Maximum distance in meters from a relevant latitude and longitude that the pass is relevant.
  /// This number is compared to the pass’s default distance and the smaller value is used.
  final int? maxDistance;

  /// Recommended for event tickets and boarding passes; otherwise optional.
  /// Date and time when the pass becomes relevant. For example, the start time of a movie.
  /// The value must be a complete date with hours and minutes, and may optionally include seconds.
  final String? relevantDate;

  /// Optional. A list of iTunes Store item identifiers for the associated apps.
  /// Only one item in the list is used—the first item identifier for an app compatible with the current device.
  /// If the app is not installed, the link opens the App Store and shows the app.
  /// If the app is already installed, the link launches the app.
  final List<int>? associatedStoreIdentifiers;

  /// Optional. A URL to be passed to the associated app when launching it.
  /// The app receives this URL in the application:didFinishLaunchingWithOptions: and application:openURL:options:
  /// methods of its app delegate.
  /// If this key is present, the associatedStoreIdentifiers key must also be present.
  final String? appLaunchURL;

  /// Optional. Date and time when the pass expires.
  /// The value must be a complete date with hours and minutes, and may optionally include seconds.
  final String? expirationDate;

  /// Optional. Indicates that the pass is void—for example, a one time use coupon that has been redeemed. The default value is false.
  final bool? voided;

  const PasskitPass({
    required this.formatVersion,
    required this.passTypeIdentifier,
    required this.description,
    required this.teamIdentifier,
    required this.organizationName,
    required this.serialNumber,
    this.storeCard,
    this.coupon,
    this.generic,
    this.eventTicket,
    this.boardingPass,
    this.labelColor,
    this.backgroundColor,
    this.foregroundColor,
    this.webServiceURL,
    this.authenticationToken,
    this.associatedStoreIdentifiers,
    this.appLaunchURL,
    this.expirationDate,
    this.voided,
    this.groupingIdentifier,
    this.logoText,
    this.barcodes,
    this.locations,
    this.maxDistance,
    this.relevantDate,
  });

  factory PasskitPass.fromJson(Map<String, dynamic> json) {
    return PasskitPass(
      formatVersion: json['formatVersion'] as int,
      passTypeIdentifier: json['passTypeIdentifier'],
      description: json['description'],
      teamIdentifier: json['teamIdentifier'],
      organizationName: json['organizationName'],
      serialNumber: json['serialNumber'],
      logoText: json['logoText'],
      groupingIdentifier: json['groupingIdentifier'],
      storeCard: _structure('storeCard', json),
      eventTicket: _structure('eventTicket', json),
      boardingPass: _structure('boardingPass', json),
      generic: _structure('generic', json),
      coupon: _structure('coupon', json),
      labelColor: color(color: json['labelColor']),
      backgroundColor: color(color: json['backgroundColor']),
      foregroundColor: color(color: json['foregroundColor']),
      webServiceURL: json['webServiceURL'],
      authenticationToken: json['authenticationToken'],
      appLaunchURL: json['appLaunchURL'],
      associatedStoreIdentifiers:
          (json['associatedStoreIdentifiers'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      expirationDate: json['expirationDate'],
      voided: json['voided'] as bool?,
      relevantDate: json['relevantDate'],
      maxDistance: json['maxDistance'] as int?,
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => PasskitLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      barcodes: (json['barcodes'] as List<dynamic>?)
          ?.map((e) => PasskitBarcode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'formatVersion': formatVersion,
      'organizationName': organizationName,
      'passTypeIdentifier': passTypeIdentifier,
      'serialNumber': serialNumber,
      'teamIdentifier': teamIdentifier,
      'webServiceURL': webServiceURL,
      'authenticationToken': authenticationToken,
      'barcodes': barcodes
          ?.map((e) => e.toJson()..removeWhere((_, value) => value == null))
          .toList(),
      'backgroundColor': fromColor(backgroundColor),
      'foregroundColor': fromColor(foregroundColor),
      'labelColor': fromColor(labelColor),
      'groupingIdentifier': groupingIdentifier,
      'logoText': logoText,
      'storeCard': storeCard?.toJson()
        ?..removeWhere((_, value) => value == null),
      'generic': generic?.toJson()?..removeWhere((_, value) => value == null),
      'eventTicket': eventTicket?.toJson()
        ?..removeWhere((_, value) => value == null),
      'coupon': coupon?.toJson()?..removeWhere((_, value) => value == null),
      'boardingPass': boardingPass?.toJson()
        ?..removeWhere((_, value) => value == null),
      'locations': locations
          ?.map((e) => e.toJson()..removeWhere((_, value) => value == null))
          .toList(),
      'maxDistance': maxDistance,
      'relevantDate': relevantDate,
      'associatedStoreIdentifiers': associatedStoreIdentifiers,
      'appLaunchURL': appLaunchURL,
      'expirationDate': expirationDate,
      'voided': voided,
    };
  }

  static PasskitStructure? _structure(String type, Map<String, dynamic> json) {
    return json[type] != null ? PasskitStructure.fromJson(json[type]) : null;
  }

  @override
  List<Object?> get props => [
        formatVersion,
        storeCard,
        coupon,
        generic,
        eventTicket,
        boardingPass,
        passTypeIdentifier,
        description,
        teamIdentifier,
        labelColor,
        backgroundColor,
        foregroundColor,
        organizationName,
        webServiceURL,
        serialNumber,
        authenticationToken,
        associatedStoreIdentifiers,
        appLaunchURL,
        expirationDate,
        voided,
        groupingIdentifier,
        logoText,
        barcodes,
        locations,
      ];
}
