# Facetest

A Flutter face verification and face capture package built with Google ML Kit.

`facetest` provides a ready-to-use face verification experience that guides users through different facial poses and captures their face while performing real-time face detection.

The package can be used for identity verification, KYC onboarding, biometric authentication flows, user registration, and other applications that require face-based verification.

## Features

* Real-time face detection using Google ML Kit.
* Face positioning and alignment guidance.
* Face pose detection.
* Supports multiple facial actions and directions:

  * Look straight at the camera.
  * Look left.
  * Look right.
  * Look up.
  * Look down.
  * Smile.
* Visual instructions to guide users during verification.
* Face capture and verification flow.
* Customizable face capture configuration.
* Custom face verification UI components.
* Progress indication during the verification process.
* Success and error states.
* Optional sound instructions.
* Support for Android and iOS.
* Customizable colors and UI components.

## How Face Verification Works

The package guides the user through a sequence of facial instructions.

For example:

1. Position your face inside the guide.
2. Look directly at the camera.
3. Look to the left.
4. Look to the right.
5. Look up.
6. Look down.
7. Smile.
8. Complete the verification.

The package uses Google ML Kit's face detection capabilities to detect the user's face and determine whether the required facial pose or action has been performed.

---

## Installation

Add `facetest` to your Flutter application's `pubspec.yaml`:

```yaml
dependencies:
  facetest: ^1.0.0+1
```

Then run:

```bash
flutter pub get
```

Import the package:

```dart
import 'package:facetest/facetest.dart';
```

---

## Camera Permissions

`facetest` requires access to the device camera to perform face detection, face capture, and face verification.

The application using this package must request and obtain camera permission before starting the face verification process.

### Android

Add the following camera permission to:

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

For example:

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

### iOS

Add the camera usage description to:

`ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to perform face verification.</string>
```

For example:

```xml
<dict>

    <key>NSCameraUsageDescription</key>
    <string>This app requires camera access to perform face verification.</string>

    <!-- Other application configuration -->

</dict>
```

### Permission Requirement

The user must grant camera permission before using the face verification feature.

If camera permission is denied, the face verification process cannot be completed.

Your application should handle the permission state appropriately and, if necessary, guide the user to the device settings to enable camera access.

---

## Android Release Build / ProGuard

If you encounter issues when building your application in **release mode**, particularly when ML Kit face detection works in debug mode but fails in release mode, you may need to add the following ProGuard/R8 rules.

Add these rules to your Android ProGuard configuration:

```proguard
# ML Kit Face Detection uses reflection; R8 may strip required classes in release builds.

-keep class com.google.mlkit.** { *; }

-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }

-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }

-keep class com.google.android.gms.internal.mlkit_common.** { *; }

-dontwarn com.google.mlkit.**

-dontwarn com.google.android.gms.**
```

These rules help prevent R8 from removing ML Kit classes that may be required at runtime.

---

## Usage

After installing the package and configuring camera permissions, you can use `facetest` in your Flutter application to start the face verification flow.

Refer to the package API and example application for the available configuration options and customization.

---

## Platform Support

| Platform | Supported |
| -------- | --------- |
| Android  | ✅ Yes     |
| iOS      | ✅ Yes     |

---

## Requirements

* Flutter
* Dart
* Android or iOS device with a working camera
* Camera permission
* Google ML Kit Face Detection support

---

## Use Cases

`facetest` can be used for:

* KYC and identity verification.
* User onboarding.
* Biometric authentication.
* Account registration.
* Customer verification.
* Financial applications.
* Healthcare applications.
* Access control systems.
* Any application requiring face-based verification.

---

## License

This package is provided for use according to the license specified in the package repository.

````

### One thing I recommend before publishing

Your README says:

> "The application using this package must request and obtain camera permission"

That is correct **if your package does not request permission itself**.

If `facetest` already requests camera permission internally, we should change that wording because users shouldn't be told to implement something your package already handles.

Also, after updating the README, run:

```bash
dart pub publish --dry-run
````

If it says **0 warnings**, then:

```bash
dart pub publish
```
