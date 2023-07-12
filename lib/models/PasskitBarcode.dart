import 'package:equatable/equatable.dart';

class PasskitBarcode extends Equatable {
  /// Required. Barcode format. For the barcode dictionary, you can use only the following values:
  /// PKBarcodeFormatQR, PKBarcodeFormatPDF417, or PKBarcodeFormatAztec.
  /// For dictionaries in the barcodes array, you may also use PKBarcodeFormatCode128.
  final String format;

  /// Required. Message or payload to be displayed as a barcode.
  final String message;

  /// Required. Text encoding that is used to convert the message from the string representation
  /// to a data representation to render the barcode. The value is typically iso-8859-1, but you may
  /// use another encoding that is supported by your barcode scanning infrastructure.
  final String messageEncoding;

  /// Optional. Text displayed near the barcode.
  /// For example, a human-readable version of the barcode data in case the barcode doesn’t scan.
  final String? altText;

  PasskitBarcode({
    required this.format,
    required this.message,
    required this.messageEncoding,
    this.altText,
  });

  factory PasskitBarcode.fromJson(Map<String, dynamic> json) {
    return PasskitBarcode(
      format: json['format'],
      message: json['message'],
      messageEncoding: json['messageEncoding'],
      altText: json['altText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'message': message,
      'messageEncoding': messageEncoding,
      'altText': altText,
    };
  }

  @override
  List<Object?> get props => [
        format,
        message,
        messageEncoding,
        altText,
      ];
}
