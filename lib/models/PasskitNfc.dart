import 'package:equatable/equatable.dart';

class PasskitNfc extends Equatable {
  /// Required. The public encryption key the Value Added Services protocol uses.
  /// Use a Base64-encoded X.509 SubjectPublicKeyInfo structure that contains an ECDH public key for group P256.
  final String encryptionPublicKey;

  /// Required. The payload the device transmits to the Apple Pay terminal.
  /// The size must be no more than 64 bytes. The system truncates messages longer than 64 bytes.
  final String message;

  /// Required. Text encoding that is used to convert the message from the string representation
  /// to a data representation to render the barcode. The value is typically iso-8859-1, but you may
  /// use another encoding that is supported by your barcode scanning infrastructure.
  final bool? requiresAuthentication;

  PasskitNfc({
    required this.encryptionPublicKey,
    required this.message,
    this.requiresAuthentication,
  });

  factory PasskitNfc.fromJson(Map<String, dynamic> json) {
    return PasskitNfc(
      encryptionPublicKey: json['encryptionPublicKey'],
      message: json['message'],
      requiresAuthentication: json['requiresAuthentication'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encryptionPublicKey': encryptionPublicKey,
      'message': message,
      'requiresAuthentication': requiresAuthentication,
    };
  }

  @override
  List<Object?> get props => [
        encryptionPublicKey,
        message,
        requiresAuthentication,
      ];
}
