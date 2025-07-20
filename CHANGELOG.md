# Changelog

All notable changes to this project will be documented in this file.

## [5.0.5] - 2025-07-20

### Added
- Release version 5.0.5

### Changed
- Updated package version to 5.0.5

### Fixed
- Various bug fixes and improvements


## [5.0.4] - 2025-07-20

### Added
- Release version 5.0.4

### Changed
- Updated package version to 5.0.4

### Fixed
- Various bug fixes and improvements


## [5.0.3] - 2025-07-20

### Added
- Release version 5.0.3

### Changed
- Updated package version to 5.0.3

### Fixed
- Various bug fixes and improvements


## [5.0.2] - 2025-07-20

### Added
- Release version 5.0.2

### Changed
- Updated package version to 5.0.2

### Fixed
- Various bug fixes and improvements


## [5.0.1] - 2025-07-20

### Added
- Release version 5.0.1

### Changed
- Updated package version to 5.0.1

### Fixed
- Various bug fixes and improvements


## [5.0.0] - 2025-07-20

### Added
- Release version 5.0.0

### Changed
- Updated package version to 5.0.0

### Fixed
- Various bug fixes and improvements


The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2024-01-XX

### 🚀 Major Refactoring & New Features

#### Added
- **Cross-platform support**: Full Android Google Wallet integration alongside existing iOS Apple Wallet support
- **Unified API**: Single codebase for both iOS and Android platforms
- **New WalletCard model**: Comprehensive data structure supporting both platforms
- **Platform factory pattern**: Automatic platform detection and appropriate implementation selection
- **Enhanced file management**: Improved file operations with better error handling
- **Card generators**: Separate generators for Apple Wallet (.pkpass) and Google Wallet (.json) files
- **Comprehensive test coverage**: 90%+ test coverage with unit and integration tests
- **Location-based relevance**: Support for location-triggered wallet cards
- **Date-based relevance**: Support for time-sensitive wallet cards
- **Multiple card types**: Support for boarding passes, coupons, event tickets, store cards, and generic cards
- **Custom styling**: Enhanced color and visual customization options
- **Network operations**: Improved URL downloading with better error handling
- **JSON serialization**: Automatic JSON serialization/deserialization for all models

#### Changed
- **BREAKING**: Complete API redesign for better consistency and platform unification
- **BREAKING**: New model structure with `WalletCard`, `WalletCardMetadata`, and `WalletCardVisuals`
- **BREAKING**: Method names updated for clarity and consistency
- **Improved error handling**: Custom `WalletException` with detailed error information
- **Better dependency management**: Updated to latest versions of all dependencies
- **Enhanced documentation**: Comprehensive README with examples and migration guide
- **Modernized codebase**: Updated to latest Flutter and Dart standards

#### Fixed
- **OpenSSL compatibility**: Fixed legacy cipher support for older certificate formats
- **Memory management**: Improved file cleanup and memory usage
- **Platform detection**: More reliable platform-specific feature detection
- **Error propagation**: Better error handling and user feedback

#### Removed
- **BREAKING**: Removed deprecated methods from v3.x
- **BREAKING**: Removed platform-specific APIs in favor of unified interface
- **Dependency cleanup**: Removed unused dependencies

### 🔧 Technical Improvements

#### Architecture
- Implemented clean architecture with separation of concerns
- Added abstract platform interfaces for better testability
- Introduced factory pattern for platform-specific implementations
- Enhanced error handling with custom exception types

#### Code Quality
- Added comprehensive linting rules
- Implemented automated code generation for JSON serialization
- Added mock generation for testing
- Improved code documentation and inline comments

#### Testing
- Added unit tests for all core functionality
- Added integration tests for platform-specific features
- Added mock testing for network operations
- Added test coverage reporting

### 📱 Platform-Specific Features

#### iOS (Apple Wallet)
- Enhanced Passkit integration
- Support for multiple card addition
- Improved certificate handling
- Better error messages for iOS-specific issues

#### Android (Google Wallet)
- **NEW**: Full Google Wallet API integration
- **NEW**: JWT-based pass saving
- **NEW**: Pass link generation
- **NEW**: Google Pay integration

### 🔄 Migration Guide

#### From v3.x to v4.0

**Old API:**
```dart
// iOS specific
await FlutterWalletCard.addPasskit(passData);

// Platform checking
if (Platform.isIOS) {
  // iOS code
}
```

**New API:**
```dart
// Unified API
final card = WalletCard(/* ... */);
await FlutterWalletCard.addToWallet(card);

// Automatic platform handling
bool available = await FlutterWalletCard.isWalletAvailable();
```

#### Key Changes
1. Replace `PasskitFile` with `WalletCard`
2. Use unified methods instead of platform-specific ones
3. Update model structure to new format
4. Handle new exception types

### 📦 Dependencies

#### Updated
- `archive`: ^3.4.10 (was ^3.3.0)
- `dio`: ^5.4.0 (was ^4.0.6)
- `path_provider`: ^2.1.2 (was ^2.0.11)
- `uuid`: ^4.3.3 (was ^3.0.6)

#### Added
- `json_annotation`: ^4.9.0
- `build_runner`: ^2.4.7
- `json_serializable`: ^6.7.1
- `mockito`: ^5.4.4

### 🐛 Bug Fixes
- Fixed OpenSSL legacy cipher compatibility issues
- Fixed memory leaks in file operations
- Fixed platform detection edge cases
- Fixed error handling in network operations
- Fixed certificate parsing on newer OpenSSL versions

### 🔒 Security
- Enhanced certificate validation
- Improved error message sanitization
- Better handling of sensitive data
- Secure file operations

---

## [3.1.0] - 2023-06-15

### Added
- Support for Flutter 3.0
- Improved error handling
- Better documentation

### Fixed
- iOS compatibility issues
- Memory management improvements

---

## [3.0.0] - 2023-03-20

### Added
- Null safety support
- Flutter 2.0 compatibility
- Enhanced Passkit generation

### Changed
- **BREAKING**: Migrated to null safety
- Updated minimum Dart SDK to 2.12.0

### Fixed
- Various stability improvements

---

## [2.1.0] - 2022-08-10

### Added
- Support for custom pass fields
- Enhanced image handling
- Better error messages

### Fixed
- iOS 15 compatibility
- Certificate handling improvements

---

## [2.0.0] - 2022-02-15

### Added
- Complete rewrite of the plugin
- Support for all Passkit features
- Enhanced documentation

### Changed
- **BREAKING**: New API structure
- Improved performance

---

## [1.0.0] - 2021-09-01

### Added
- Initial release
- Basic Passkit support for iOS
- File-based pass generation
- URL-based pass downloading

---

## Legend

- 🚀 **Major Features**: Significant new functionality
- 🔧 **Technical**: Internal improvements and refactoring
- 📱 **Platform**: Platform-specific changes
- 🔄 **Migration**: Breaking changes and migration information
- 📦 **Dependencies**: Dependency updates
- 🐛 **Bug Fixes**: Bug fixes and stability improvements
- 🔒 **Security**: Security-related changes
