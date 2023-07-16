import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';

class Fs {
  Future<bool> unpack({required String path}) async {
    final file = File(path);
    final directory = Directory(Path.withoutExtension(path));

    if (!file.existsSync()) throw Exception('Missing passkit file');
    directory.createSync(recursive: true);

    try {
      await _createFile(directory: directory, file: file);
      return true;
    } catch (exception) {
      delete(directory, file);
      throw exception;
    }
  }

  void pack({
    required Directory directory,
    required String filename,
  }) {
    ZipFileEncoder().zipDirectory(directory, filename: filename);
  }

  Future<Directory> createDirectory({required String name}) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$name')..createSync(recursive: true);
  }

  void delete(Directory directory, File file) {
    file.deleteSync();
    directory.deleteSync(recursive: true);
  }

  Future<void> _createFile({
    required Directory directory,
    required File file,
  }) async {
    final archive = file.readAsBytesSync();
    final files = ZipDecoder().decodeBytes(archive);

    for (final file in files) {
      final filename = '${directory.path}/${file.name}';

      if (file.isFile) {
        File(filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content, flush: true);
      } else {
        await Directory(filename).create(recursive: true);
      }
    }
  }
}
