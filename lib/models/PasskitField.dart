import 'package:equatable/equatable.dart';

class PasskitField extends Equatable {
  /// Required. The key must be unique within the scope of the entire pass. For example, “departure-gate.”
  final String key;

  /// Required. Value of the field, for example, 42.
  final String value;

  /// Optional. Label text for the field.
  final String? label;

  /// Optional. Format string for the alert text that is displayed when the pass is updated.
  /// The format string must contain the escape %@, which is replaced with the field’s new value.
  /// For example, “Gate changed to %@.”
  /// If you don’t specify a change message, the user isn’t notified when the field changes.
  final String? changeMessage;

  PasskitField({
    required this.key,
    required this.value,
    this.label,
    this.changeMessage,
  });

  factory PasskitField.fromJson(Map<String, dynamic> json) {
    return PasskitField(
      key: json['key'],
      value: json['value'],
      label: json['label'],
      changeMessage: json['changeMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'label': label,
      'changeMessage': changeMessage
    };
  }

  @override
  List<Object?> get props => [key, label, value, changeMessage];
}
