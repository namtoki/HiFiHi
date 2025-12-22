# Auracast Hub

A Flutter Android application for detecting and connecting to Bluetooth LE Audio (Auracast) broadcasts.

## Features

- User authentication with AWS Cognito (sign up, login, password reset)
- Scanning and detecting Auracast broadcasts
- Displaying broadcast information (name, ID, signal strength, encryption status)
- Connection control using BASS (Broadcast Audio Scan Service) (in development)

## Requirements

- **Android 13 (API 33) or higher** - Required for LE Audio support
- Bluetooth hardware with LE Audio support
- [Devbox](https://www.jetify.com/devbox) - Development environment management (auto-installs Flutter SDK, JDK 17)
- Android SDK (install via Android Studio)
- Terraform 1.0.0 or higher (for AWS infrastructure)
- AWS CLI (configured)

## Development Environment Setup

This project uses **Devbox** to manage the development environment.

```bash
# If Devbox is not installed
curl -fsSL https://get.jetify.com/devbox | bash

# Enter the development environment (Flutter SDK and JDK 17 are automatically set up)
devbox shell
```

> **Note**: All subsequent commands should be run inside `devbox shell` or using the `devbox run -- <command>` format.

### Android SDK Setup

1. Install [Android Studio](https://developer.android.com/studio)
2. Set up SDK in Android Studio (automatic on first launch)
3. Install cmdline-tools:
   ```bash
   sdkmanager "cmdline-tools;latest"
   ```

The devbox shell automatically sets the `ANDROID_HOME` environment variable and adds `sdkmanager`, `avdmanager`, and `emulator` commands to PATH.

## AWS Infrastructure Setup

### 1. Terraform Configuration

```bash
cd infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 3. Configure Flutter App

After deployment, retrieve the output values and update `app/lib/amplifyconfiguration.dart`:

```bash
terraform output flutter_amplify_config
```

Example output:
```
{
  "identityPoolId" = "ap-northeast-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  "region" = "ap-northeast-1"
  "userPoolClientId" = "xxxxxxxxxxxxxxxxxxxxxxxxxx"
  "userPoolId" = "ap-northeast-1_xxxxxxxxx"
}
```

Set these values in the corresponding fields in `amplifyconfiguration.dart`.

## Build

### Install Dependencies

```bash
cd app
flutter pub get
```

### Static Analysis

```bash
cd app
flutter analyze
```

### Run Tests

```bash
cd app
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

## Building APK

### Debug APK

```bash
cd app
flutter build apk --debug
```

Output: `app/build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
cd app
flutter build apk --release
```

Output: `app/build/app/outputs/flutter-apk/app-release.apk`

### Split APK (per ABI)

```bash
cd app
flutter build apk --split-per-abi
```

Output:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (x86_64)

### App Bundle (for Google Play)

```bash
cd app
flutter build appbundle
```

Output: `app/build/app/outputs/bundle/release/app-release.aab`

## Running on Emulator

### 1. Create Emulator

Using Android Studio:
1. Open Tools → Device Manager
2. Click "Create Device"
3. Select a device (Pixel 6 recommended)
4. Select system image with **API 33 or higher**
5. Click "Finish"

Using command line:
```bash
# Check available system images
sdkmanager --list | grep "system-images"

# Download system image
# For Apple Silicon Mac, use arm64-v8a
sdkmanager "system-images;android-33;google_apis;arm64-v8a"

# For Intel Mac / Linux, use x86_64
# sdkmanager "system-images;android-33;google_apis;x86_64"

# Create AVD (match the system image you downloaded)
avdmanager create avd -n Pixel6_API33 -k "system-images;android-33;google_apis;arm64-v8a" -d "pixel_6"
```

### 2. Launch Emulator

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch Pixel6_API33

# Or launch directly
emulator -avd Pixel6_API33
```

### 3. Run App

```bash
cd app
flutter run
```

> **Note**: Actual Bluetooth LE Audio functionality does not work on emulators. Only UI verification is possible.

## Running on USB-Connected Device

### 1. Prepare Device

1. Enable **Developer Options** on your Android device
   - Settings → About phone → Tap Build number 7 times
2. Enable **USB Debugging**
   - Settings → Developer options → USB debugging
3. Connect to PC via USB cable
4. Select "Allow" when prompted "Allow USB debugging?" on the device

### 2. Verify Connection

```bash
# Check connected devices
flutter devices

# Example output:
# RQ8M802XXXX (mobile) • RQ8M802XXXX • android-arm64 • Android 14 (API 34)
```

Or verify with adb:
```bash
adb devices
```

### 3. Run App

```bash
cd app

# If only one device is connected
flutter run

# If multiple devices are connected, specify device ID
flutter run -d RQ8M802XXXX
```

### 4. Run in Release Mode

```bash
cd app
flutter run --release
```

### 5. Hot Reload / Hot Restart

While app is running:
- `r` key: Hot reload (redraw while preserving state)
- `R` key: Hot restart (restart app)
- `q` key: Quit

## Installing APK

### Using adb

```bash
# Install debug APK
adb install app/build/app/outputs/flutter-apk/app-debug.apk

# Reinstall over existing app
adb install -r app/build/app/outputs/flutter-apk/app-debug.apk
```

### Using flutter install

```bash
cd app
flutter install
```

## Troubleshooting

### Devbox Environment Issues

```bash
# Rebuild Devbox environment
devbox rm
devbox install

# Or re-enter shell
exit
devbox shell
```

### Device Not Recognized

```bash
# Restart adb server
adb kill-server
adb start-server
adb devices
```

### Bluetooth Permission Error

Grant Bluetooth permissions when prompted on first app launch:
- `BLUETOOTH_SCAN`
- `BLUETOOTH_CONNECT`

### LE Audio Not Supported Error

- Use a device with Android 13 or higher
- Some devices do not have hardware support for LE Audio

### Build Error

```bash
cd app
flutter clean
flutter pub get
flutter run
```

## Project Structure

```
Auracast-Hub/
├── app/                          # Flutter application
│   ├── android/                  # Android native code
│   │   └── app/src/main/kotlin/
│   │       └── com/auracast/auracast_hub/
│   │           ├── AuracastPlugin.kt      # Flutter plugin
│   │           ├── MainActivity.kt
│   │           └── bluetooth/
│   │               ├── AuracastScanner.kt # BLE scanner
│   │               └── BluetoothUuids.kt  # UUID constants
│   ├── lib/                      # Dart code
│   │   ├── main.dart             # App entry point
│   │   ├── amplifyconfiguration.dart  # Cognito configuration
│   │   ├── screens/
│   │   │   ├── auth/             # Authentication screens
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   ├── confirm_signup_screen.dart
│   │   │   │   └── reset_password_screen.dart
│   │   │   └── broadcast_list_screen.dart
│   │   └── services/
│   │       ├── auracast_service.dart  # BLE service
│   │       └── auth_service.dart      # Authentication service
│   ├── test/
│   └── pubspec.yaml
├── infrastructure/               # AWS infrastructure
│   ├── terraform/
│   │   ├── provider.tf           # AWS provider configuration
│   │   ├── variables.tf          # Variable definitions
│   │   ├── cognito.tf            # Cognito resources
│   │   ├── outputs.tf            # Output values
│   │   └── terraform.tfvars.example
│   └── README.md
├── devbox.json                   # Devbox environment configuration (Flutter, JDK 17)
├── devbox.lock                   # Devbox dependency lock file
├── request.md                    # Technical specification
├── CLAUDE.md                     # Claude Code guide
└── README.md
```

## License

MIT License
