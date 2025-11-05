import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'wallet_platform.dart';

/// File management utility for wallet card operations
class FileManager {
  static const String _defaultDirectoryName = 'wallet_cards';

  /// Create a temporary directory for card generation
  Future<Directory> createTempDirectory(String name) async {
    Directory tempDir;
    try {
      tempDir = await getTemporaryDirectory();
    } catch (e) {
      // Fallback for test environment
      tempDir = Directory.systemTemp;
    }
    final cardTempDir =
        Directory(path.join(tempDir.path, _defaultDirectoryName, name));

    if (cardTempDir.existsSync()) {
      await cardTempDir.delete(recursive: true);
    }

    await cardTempDir.create(recursive: true);
    return cardTempDir;
  }

  /// Create output directory for generated cards
  Future<Directory> createOutputDirectory() async {
    Directory appDir;
    try {
      appDir = await getApplicationDocumentsDirectory();
    } catch (e) {
      // Fallback for test environment
      appDir = Directory.systemTemp;
    }
    final outputDir = Directory(path.join(appDir.path, _defaultDirectoryName));

    if (!outputDir.existsSync()) {
      await outputDir.create(recursive: true);
    }

    return outputDir;
  }

  /// Create an output file with a unique name if needed
  Future<File> createOutputFile(String filename) async {
    final outputDir = await createOutputDirectory();
    var outputFile = File(path.join(outputDir.path, filename));

    // If file exists, create a unique name
    if (outputFile.existsSync()) {
      final baseName = path.basenameWithoutExtension(filename);
      final extension = path.extension(filename);
      var counter = 1;

      do {
        final newFilename = '${baseName}_$counter$extension';
        outputFile = File(path.join(outputDir.path, newFilename));
        counter++;
      } while (outputFile.existsSync());
    }

    return outputFile;
  }

  /// Extract archive to a directory
  Future<Directory> extractArchive(File archiveFile,
      {String? targetDirName}) async {
    if (!archiveFile.existsSync()) {
      throw WalletException('Archive file does not exist: ${archiveFile.path}');
    }

    final targetName =
        targetDirName ?? path.basenameWithoutExtension(archiveFile.path);
    final extractDir = await createTempDirectory('extract_$targetName');

    try {
      final bytes = await archiveFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = path.join(extractDir.path, file.name);

        if (file.isFile) {
          final outputFile = File(filename);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filename).create(recursive: true);
        }
      }

      return extractDir;
    } catch (e) {
      await extractDir.delete(recursive: true);
      throw WalletException('Failed to extract archive: $e');
    }
  }

  /// Create a zip archive from a directory
  Future<File> createArchive(Directory sourceDir, File outputFile) async {
    if (!sourceDir.existsSync()) {
      throw WalletException(
          'Source directory does not exist: ${sourceDir.path}');
    }

    try {
      final encoder = ZipFileEncoder();
      await encoder.zipDirectory(sourceDir, filename: outputFile.path);
      return outputFile;
    } catch (e) {
      throw WalletException('Failed to create archive: $e');
    }
  }

  /// Download file from URL
  Future<File> downloadFile(String url, {String? filename}) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        throw WalletException(
            'Failed to download file: HTTP ${response.statusCode}');
      }

      final downloadFilename = filename ?? _generateFilenameFromUrl(url);
      final outputFile = await createOutputFile(downloadFilename);

      final sink = outputFile.openWrite();
      await response.pipe(sink);
      await sink.close();
      client.close();

      return outputFile;
    } catch (e) {
      throw WalletException('Failed to download file from $url: $e');
    }
  }

  /// Clean up old files and directories
  Future<void> cleanup({Duration? olderThan}) async {
    final maxAge = olderThan ?? const Duration(days: 7);
    final cutoffTime = DateTime.now().subtract(maxAge);

    try {
      final tempDir = await getTemporaryDirectory();
      final walletTempDir =
          Directory(path.join(tempDir.path, _defaultDirectoryName));

      if (walletTempDir.existsSync()) {
        await for (final entity in walletTempDir.list()) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await entity.delete(recursive: true);
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  /// Validate file format
  bool isValidWalletFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return extension == '.pkpass' || extension == '.json';
  }

  /// Get file size in bytes
  Future<int> getFileSize(File file) async {
    if (!file.existsSync()) {
      throw WalletException('File does not exist: ${file.path}');
    }

    final stat = await file.stat();
    return stat.size;
  }

  /// Generate a random filename
  String generateRandomFilename({String extension = '.tmp'}) {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(10000);
    return 'file_${timestamp}_$randomSuffix$extension';
  }

  /// Generate a unique filename with base name and extension
  String generateUniqueFilename(String baseName, String extension) {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(10000);
    return '${baseName}_${timestamp}_$randomSuffix.$extension';
  }

  String _generateFilenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      if (segments.isNotEmpty) {
        final lastSegment = segments.last;
        if (lastSegment.contains('.')) {
          return lastSegment;
        }
      }

      return generateRandomFilename(extension: '.download');
    } catch (e) {
      return generateRandomFilename(extension: '.download');
    }
  }

  /// Clean up old files in a directory
  Future<void> cleanupOldFiles(Directory directory,
      {required Duration maxAge}) async {
    if (!directory.existsSync()) return;

    final cutoffTime = DateTime.now().subtract(maxAge);

    await for (final entity in directory.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoffTime)) {
          await entity.delete();
        }
      }
    }
  }
}
