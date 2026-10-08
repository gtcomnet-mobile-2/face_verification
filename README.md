# Facetest

A Flutter face verification and face capture package built on `google_mlkit_face_detection`.

`facetest` provides a ready-to-use verification experience that guides users through a series of facial poses and captures their face while performing real-time face detection. It is suited to identity verification, KYC onboarding, biometric authentication, user registration, and any flow that needs face-based verification.

## Table of Contents

- [Facetest](#facetest)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [How It Works](#how-it-works)
  - [Platform Support](#platform-support)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Platform Setup](#platform-setup)
    - [Android](#android)
    - [iOS](#ios)
    - [Handling Permissions (Android and iOS)](#handling-permissions-android-and-ios)
  - [Usage](#usage)

## Features

- Real-time face detection using Google ML Kit
- Face positioning and alignment guidance
- Face pose detection
- Multiple facial actions and directions:
  - Look straight at the camera
  - Look left
  - Look right
  - Look up
  - Look down
  - Smile
- Visual instructions to guide users during verification
- Face capture and verification flow
- Customizable face capture configuration
- Custom face verification UI components
- Progress indication during verification
- Success and error states
- Optional sound instructions
- Customizable colors and UI components
- Android and iOS support

## How It Works

The package guides the user through a sequence of facial instructions, for example:

1. Position your face inside the guide.
2. Look directly at the camera.
3. Look to the left.
4. Look to the right.
5. Look up.
6. Look down.
7. Smile.
8. Complete the verification.

It uses Google ML Kit's face detection to find the user's face and determine whether the required pose or action has been performed.

## Platform Support

| Platform | Supported |
| -------- | --------- |
| Android  | ✅ Yes    |
| iOS      | ✅ Yes    |

## Requirements

- Flutter and Dart
- An Android or iOS device with a working camera
- Camera permission granted by the user
- Google ML Kit Face Detection support

## Installation

Add `facetest` to your app's `pubspec.yaml`:

```yaml
dependencies:
  facetest: ^1.0.0+1
```

Install the package:

```bash
flutter pub get
```

Import it:

```dart
import 'package:facetest/facetest.dart';
```

## Platform Setup

`facetest` needs camera access to perform face detection, capture, and verification. Your app must declare the camera permission on each platform and request it at runtime before starting the verification flow.

### Android

**1. Add the camera permission**

In `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" />

    <application
        android:label="Your App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <!-- Your application configuration -->

    </application>
</manifest>
```

**2. Configure ProGuard / R8 for release builds**

ML Kit face detection uses reflection, and R8 may strip the classes it needs. If detection works in debug mode but fails in release mode, add the rules below.

Create `android/app/proguard-rules.pro` and paste in:

```proguard
# ML Kit Face Detection uses reflection; R8 may strip required classes in release builds.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_common.** { *; }

-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
```

**3. Reference the rules in Gradle**

In `android/app/build.gradle.kts`:

```kotlin
android {
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByNam## Use Cases

- KYC and identity verification
- User onboarding and account registration
- Biometric authentication
- Customer verification
- Financial applications
- Healthcare applications
- Any application requiring face-based verificatione("debug")

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}
```

### iOS

Add the camera usage description to `ios/Runner/Info.plist`:

```xml
<dict>
    <key>NSCameraUsageDescription</key>
    <string>This app requires camera access to perform face verification.</string>

    <!-- Other application configuration -->
</dict>
```

### Handling Permissions (Android and iOS)

- The user must grant camera permission before verification can start.
- If permission is denied, the verification process cannot be completed.
- Your app should handle each permission state, and where needed guide the user to device settings to enable camera access.

## Usage

After installing the package and configuring camera permissions, use `facetest` in your app to start the face verification flow.

Refer to the package API documentation and the example application for available configuration options and customization.

<!-- ## Use Cases

- KYC and identity verification
- User onboarding and account registration
- Biometric authentication
- Customer verification
- Financial applications
- Healthcare applications
- Any application requiring face-based verification -->
