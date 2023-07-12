import 'dart:io';
import 'package:equatable/equatable.dart';

import 'package:flutter_wallet_card/core/fs.dart';
import 'package:flutter_wallet_card/core/passkit.dart';
import 'package:flutter_wallet_card/models/PasskitImage.dart';
import 'package:flutter_wallet_card/models/PasskitPass.dart';

class PasskitFile extends Equatable {
  /// Required. Unique passkit identifier
  final String id;

  /// Required. .pkpass [File] reference
  final File file;

  /// Required. [Directory] containing pass.json and images
  final Directory directory;

  /// Optional. Background [PasskitImage] set.
  final PasskitImage? background;

  /// Optional. Footer [PasskitImage] set.
  final PasskitImage? footer;

  /// Optional. Icon [PasskitImage] set.
  final PasskitImage? icon;

  /// Optional. Logo [PasskitImage] set.
  final PasskitImage? logo;

  /// Optional. Strip [PasskitImage] set.
  final PasskitImage? strip;

  /// Optional. Thumbnail [PasskitImage] set.
  final PasskitImage? thumbnail;

  /// Required. [PasskitPass] implementation (card details)
  final PasskitPass json;

  PasskitFile({
    required this.id,
    required this.file,
    required this.directory,
    required this.json,
    this.background,
    this.footer,
    this.icon,
    this.logo,
    this.strip,
    this.thumbnail,
  });

  @override
  List<Object> get props => [id, json];

  Future<void> save() async {
    await Passkit().saveFromPath(id: id, file: file);
    Fs().delete(directory, file);
  }

  /// Delete current pass file from memory
  void delete() {
    Fs().delete(directory, file);
  }
}
