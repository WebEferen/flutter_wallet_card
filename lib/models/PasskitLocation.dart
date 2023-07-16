import 'package:equatable/equatable.dart';

class PasskitLocation extends Equatable {
  /// Required. Latitude, in degrees, of the location.
  final double latitude;

  /// Required. Longitude, in degrees, of the location.
  final double longitude;

  /// Optional. Altitude, in meters, of the location.
  final double? altitude;

  /// Optional. Text displayed on the lock screen when the pass is currently relevant.
  /// For example, a description of the nearby location such as “Store nearby on 1st and Main.”
  final String? relevantText;

  PasskitLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.relevantText,
  });

  factory PasskitLocation.fromJson(Map<String, dynamic> json) {
    return PasskitLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      altitude: json['altitude'],
      relevantText: json['relevantText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'relevantText': relevantText
    };
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        altitude,
        relevantText,
      ];
}
