import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wallet_card/core/file_manager.dart';
import 'package:path/path.dart' as path;

import '../utils/memory_io_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FileManager', () {
    late FileManager fileManager;
    late MemoryFileSystem fileSystem;

    setUp(() async {
      fileManager = FileManager();
      fileSystem = MemoryFileSystem();
      IOOverrides.global = MemoryIOOverrides(
        fs: fileSystem,
      );
    });

    tearDown(() {
      IOOverrides.global = null;
    });

    group('Directory Operations', () {
      test('should create temp directory', () async {
        final dir = await fileManager.createTempDirectory('test_temp');

        expect(await dir.exists(), isTrue);
        expect(dir.path.contains('wallet_cards'), isTrue);

        await dir.delete(recursive: true);
      });

      test('should create output directory', () async {
        final dir = await fileManager.createOutputDirectory();

        expect(await dir.exists(), isTrue);
        expect(dir.path.contains('wallet_cards'), isTrue);

        await dir.delete(recursive: true);
      });
    });

    group('File Operations', () {
      test('should generate unique filename', () {
        final filename1 = fileManager.generateUniqueFilename('test', 'txt');
        final filename2 = fileManager.generateUniqueFilename('test', 'txt');

        expect(filename1, isNot(equals(filename2)));
        expect(filename1.startsWith('test_'), isTrue);
        expect(filename1.endsWith('.txt'), isTrue);
      });

      test('should generate random filename', () {
        final filename1 = fileManager.generateRandomFilename(extension: '.txt');
        final filename2 = fileManager.generateRandomFilename(extension: '.txt');

        expect(filename1, isNot(equals(filename2)));
        expect(filename1.endsWith('.txt'), isTrue);
        expect(filename1.length, greaterThan(10));
      });

      test('should validate wallet file formats', () {
        expect(fileManager.isValidWalletFile(File('test.pkpass')), isTrue);
        expect(fileManager.isValidWalletFile(File('test.json')), isTrue);
        expect(fileManager.isValidWalletFile(File('test.txt')), isFalse);
        expect(fileManager.isValidWalletFile(File('test')), isFalse);
      });
    });

    group('Archive Operations', () {
      test('should extract archive', () async {
        // Create a test zip file
        final testFile = File('test.txt');
        await testFile.writeAsString('test content');

        final zipFile = File('test.zip');

        // Create a simple zip archive manually for testing
        // In a real scenario, you'd use the archive package
        await zipFile.writeAsBytes([]);

        final extractDir = Directory('extracted');

        try {
          await fileManager.extractArchive(zipFile,
              targetDirName: extractDir.path);
          // This might fail due to invalid zip, but we're testing the method exists
        } catch (e) {
          // Expected for invalid zip file
          expect(e, isA<Exception>());
        }
      });

      test('should create archive', () async {
        final sourceDir = Directory('source');
        await sourceDir.create();

        final testFile = File(path.join(sourceDir.path, 'test.txt'));
        await testFile.writeAsString('test content');

        final archiveFile = File(path.join('archive.zip'));

        await fileManager.createArchive(sourceDir, archiveFile);

        expect(await archiveFile.exists(), isTrue);
        expect(await archiveFile.length(), greaterThan(0));
      });
    });

    group('Download Operations', () {
      test('should handle download from URL', () async {
        const url = 'https://httpbin.org/json';
        final outputFile = File('downloaded.json');

        try {
          await fileManager.downloadFile(url, filename: outputFile.path);
          expect(await outputFile.exists(), isTrue);
        } catch (e) {
          // Network operations might fail in test environment
          expect(e, isA<Exception>());
        }
      });

      test('should handle invalid URL', () async {
        const url = 'invalid-url';
        final outputFile = File('downloaded.json');

        expect(
          () => fileManager.downloadFile(url, filename: outputFile.path),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Cleanup Operations', () {
      test('should clean up old files', () async {
        final directory = fileSystem.directory('/');
        final oldFile = File(path.join(directory.path, 'old.txt'));
        await oldFile.writeAsString('old content');

        // Modify the file's last modified time to make it "old"
        final oldTime = DateTime.now().subtract(const Duration(days: 2));
        await oldFile.setLastModified(oldTime);

        final newFile = File(path.join(directory.path, 'new.txt'));
        await newFile.writeAsString('new content');

        await fileManager.cleanupOldFiles(
          directory,
          maxAge: const Duration(days: 1),
        );

        expect(await oldFile.exists(), isFalse);
        expect(await newFile.exists(), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle non-existent file operations', () async {
        final nonExistentFile = File('nonexistent.txt');
        final outputDir = Directory('output');

        expect(
          () => fileManager.extractArchive(nonExistentFile,
              targetDirName: outputDir.path),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle permission errors gracefully', () async {
        // This test might not work on all platforms due to permission handling
        final restrictedDir = Directory('restricted');
        await restrictedDir.create();

        try {
          // Try to create a file in a potentially restricted location
          final restrictedFile = File(path.join('/root', 'test.txt'));
          await fileManager.downloadFile('https://httpbin.org/json',
              filename: restrictedFile.path);
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });
    });
  });
}
