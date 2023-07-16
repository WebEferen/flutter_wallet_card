import 'package:equatable/equatable.dart';
import 'package:flutter_wallet_card/models/PasskitField.dart';

class PasskitStructure extends Equatable {
  /// Optional. Additional fields to be displayed on the front of the pass.
  final List<PasskitField>? auxiliaryFields;

  /// Optional. Fields to be displayed in the header on the front of the pass.
  /// Use header fields sparingly; unlike all other fields, they remain visible when a stack of passes are displayed.
  final List<PasskitField>? headerFields;

  /// Optional. Fields to be displayed on the front of the pass.
  final List<PasskitField>? secondaryFields;

  /// Optional. Fields to be on the back of the pass.
  final List<PasskitField>? backFields;

  /// Optional. Fields to be displayed prominently on the front of the pass.
  final List<PasskitField>? primaryFields;

  /// Required for boarding passes; otherwise not allowed.
  /// Type of transit. Must be one of the following values:
  /// PKTransitTypeAir, PKTransitTypeBoat, PKTransitTypeBus, PKTransitTypeGeneric,PKTransitTypeTrain.
  final String? transitType;

  PasskitStructure({
    this.auxiliaryFields,
    this.headerFields,
    this.secondaryFields,
    this.backFields,
    this.primaryFields,
    this.transitType,
  });

  factory PasskitStructure.fromJson(Map<String, dynamic> json) {
    return PasskitStructure(
      auxiliaryFields: (json['auxiliaryFields'] as List<dynamic>?)
          ?.map((e) => PasskitField.fromJson(e as Map<String, dynamic>))
          .toList(),
      headerFields: (json['headerFields'] as List<dynamic>?)
          ?.map((e) => PasskitField.fromJson(e as Map<String, dynamic>))
          .toList(),
      secondaryFields: (json['secondaryFields'] as List<dynamic>?)
          ?.map((e) => PasskitField.fromJson(e as Map<String, dynamic>))
          .toList(),
      backFields: (json['backFields'] as List<dynamic>?)
          ?.map((e) => PasskitField.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryFields: (json['primaryFields'] as List<dynamic>?)
          ?.map((e) => PasskitField.fromJson(e as Map<String, dynamic>))
          .toList(),
      transitType: json['transitType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auxiliaryFields': auxiliaryFields
          ?.map((e) => e.toJson()..removeWhere((_, value) => value == null))
          .toList(),
      'headerFields': headerFields
          ?.map((e) => e.toJson()..removeWhere((_, value) => value == null))
          .toList(),
      'secondaryFields': secondaryFields
          ?.map((e) => e.toJson()..removeWhere((_, value) => value == null))
          .toList(),
      'backFields': backFields
          ?.map((e) => e.toJson()..removeWhere((_, value) => value == null))
          .toList(),
      'primaryFields': primaryFields
          ?.map((e) => e.toJson()..removeWhere((_, value) => value == null))
          .toList(),
      'transitType': transitType,
    };
  }

  @override
  List<Object?> get props => [
        auxiliaryFields,
        headerFields,
        secondaryFields,
        backFields,
        primaryFields,
        transitType,
      ];
}
