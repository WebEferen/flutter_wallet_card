---
layout: default
title: Platform Setup
---

# Platform Setup

Detailed setup instructions for iOS (Apple Wallet) and Android (Google Wallet).

## iOS Setup (Apple Wallet)

### Prerequisites

- iOS 11.0 or later
- Xcode 12.0 or later
- Apple Developer Account
- Valid iOS Distribution Certificate

### Step 1: Enable Wallet Capability

1. Open your iOS project in Xcode
2. Select your app target
3. Go to "Signing & Capabilities" tab
4. Click "+" and add "Wallet" capability

### Step 2: Create Pass Type ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Select "Identifiers" → "Pass Type IDs"
4. Click "+" to create a new Pass Type ID
5. Enter description and identifier (e.g., `pass.com.yourcompany.yourapp`)
6. Register the Pass Type ID

### Step 3: Create Pass Type ID Certificate

1. In the Pass Type IDs section, select your Pass Type ID
2. Click "Create Certificate"
3. Follow the instructions to generate a Certificate Signing Request (CSR)
4. Upload the CSR and download the certificate
5. Install the certificate in Keychain Access

### Step 4: Configure Info.plist

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>com.apple.developer.pass-type-identifiers</key>
<array>
    <string>pass.com.yourcompany.yourapp</string>
</array>
```

### Step 5: Update Entitlements

Ensure your `ios/Runner/Runner.entitlements` includes:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.pass-type-identifiers</key>
    <array>
        <string>pass.com.yourcompany.yourapp</string>
    </array>
</dict>
</plist>
```

### Step 6: Code Configuration

Use your Pass Type ID in your Flutter code:

```dart
final card = WalletCard(
  id: 'my-card-001',
  type: WalletCardType.storeCard,
  platformData: {
    'passTypeIdentifier': 'pass.com.yourcompany.yourapp', // Your Pass Type ID
    'teamIdentifier': 'ABC123DEF4', // Your Team ID
    'formatVersion': 1,
  },
  // ... other properties
);
```

### Finding Your Team ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to "Membership" section
3. Your Team ID is displayed there

### Testing on iOS

- **Physical Device Required**: Apple Wallet is not available in iOS Simulator
- **Development Provisioning**: Ensure your device is included in your development provisioning profile
- **Certificate Validity**: Make sure your Pass Type ID certificate is valid and installed

### Common iOS Issues

#### "Pass not supported" Error
- Verify Pass Type ID is correctly configured
- Check that the certificate is installed and valid
- Ensure Team ID matches your developer account

#### Certificate Issues
- Regenerate Pass Type ID certificate if expired
- Ensure certificate is installed in Keychain Access
- Check that the certificate matches your Pass Type ID

---

## Android Setup (Google Wallet)

### Prerequisites

- Android API level 21 or higher
- Google Cloud Console account
- Google Wallet API access

### Step 1: Enable Google Wallet API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Navigate to "APIs & Services" → "Library"
4. Search for "Google Wallet API" and enable it

### Step 2: Create Service Account

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "Service Account"
3. Fill in service account details
4. Grant necessary roles (Google Wallet API access)
5. Create and download the JSON key file

### Step 3: Configure Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Step 4: Update Build Configuration

Ensure `android/app/build.gradle` has:

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### Step 5: Set Up Issuer Account

1. Go to [Google Pay & Wallet Console](https://pay.google.com/business/console/)
2. Create an issuer account
3. Note your Issuer ID for use in your app

### Step 6: Create Object Classes

For each type of pass, create an object class:

1. In Google Pay & Wallet Console
2. Navigate to "Google Wallet API"
3. Create object classes for your pass types
4. Note the Class IDs for use in your app

### Step 7: Code Configuration

Use your Issuer ID and Class ID in your Flutter code:

```dart
final card = WalletCard(
  id: 'my-card-001',
  type: WalletCardType.storeCard,
  platformData: {
    'issuerId': 'YOUR_ISSUER_ID',
    'classId': 'YOUR_CLASS_ID',
  },
  // ... other properties
);
```

### Step 8: Authentication Setup

Store your service account JSON securely and configure authentication:

```dart
// Example of setting up authentication
// Note: In production, store credentials securely
final serviceAccountJson = {
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "your-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "your-service-account@your-project.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
};
```

### Testing on Android

- **Physical Device or Emulator**: Google Wallet works on both
- **Google Play Services**: Ensure Google Play Services is installed and updated
- **Google Account**: Device must be signed in to a Google account

### Common Android Issues

#### "Google Wallet not available" Error
- Check that Google Play Services is installed and updated
- Verify device is signed in to Google account
- Ensure Google Wallet app is installed

#### Authentication Errors
- Verify service account JSON is correct
- Check that Google Wallet API is enabled
- Ensure service account has proper permissions

#### Class/Issuer ID Issues
- Verify Issuer ID and Class ID are correct
- Check that object classes are properly configured
- Ensure issuer account is approved

---

## Cross-Platform Considerations

### Unified Code Approach

```dart
WalletCard createPlatformCard() {
  // Platform-specific data
  Map<String, dynamic> platformData;
  
  if (Platform.isIOS) {
    platformData = {
      'passTypeIdentifier': 'pass.com.yourcompany.yourapp',
      'teamIdentifier': 'YOUR_TEAM_ID',
      'formatVersion': 1,
    };
  } else if (Platform.isAndroid) {
    platformData = {
      'issuerId': 'YOUR_ISSUER_ID',
      'classId': 'YOUR_CLASS_ID',
    };
  } else {
    throw UnsupportedError('Platform not supported');
  }
  
  return WalletCard(
    id: 'cross-platform-card-001',
    type: WalletCardType.storeCard,
    platformData: platformData,
    metadata: WalletCardMetadata(
      title: 'Store Card',
      organizationName: 'Your Store',
      serialNumber: '001',
    ),
  );
}
```

### Environment Configuration

Create different configurations for development and production:

```dart
class WalletConfig {
  static const bool isDevelopment = bool.fromEnvironment('DEVELOPMENT', defaultValue: false);
  
  static String get iosPassTypeId => isDevelopment 
    ? 'pass.com.yourcompany.yourapp.dev'
    : 'pass.com.yourcompany.yourapp';
    
  static String get androidIssuerId => isDevelopment
    ? 'dev_issuer_id'
    : 'prod_issuer_id';
}
```

### Security Best Practices

1. **Never commit credentials** to version control
2. **Use environment variables** for sensitive data
3. **Implement certificate pinning** for production
4. **Validate all input data** before creating wallet cards
5. **Use secure storage** for authentication tokens

### Testing Strategy

1. **Unit Tests**: Test wallet card creation and validation
2. **Integration Tests**: Test actual wallet operations on devices
3. **Platform Tests**: Test on both iOS and Android devices
4. **Edge Cases**: Test error scenarios and edge cases

## Troubleshooting

### General Issues

- **Check platform support**: Ensure the device supports wallet functionality
- **Verify permissions**: Check that all required permissions are granted
- **Update dependencies**: Ensure all dependencies are up to date
- **Check logs**: Review device logs for detailed error messages

### Getting Help

- [GitHub Issues](https://github.com/WebEferen/flutter_wallet_card/issues)
- [Apple Developer Documentation](https://developer.apple.com/documentation/walletpasses)
- [Google Wallet API Documentation](https://developers.google.com/wallet)
- [Flutter Community](https://flutter.dev/community)