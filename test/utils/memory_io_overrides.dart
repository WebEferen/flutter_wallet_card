import 'dart:io';

import 'package:file/memory.dart';

class MemoryIOOverrides extends IOOverrides {
  final MemoryFileSystem fs;

  MemoryIOOverrides({MemoryFileSystem? fs}) : fs = fs ?? MemoryFileSystem();

  @override
  Directory createDirectory(String path) => fs.directory(path);

  @override
  File createFile(String path) => fs.file(path);

  @override
  Directory getSystemTempDirectory() => fs.directory('/tmp')..createSync();
}
