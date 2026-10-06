# Facetest

A Flutter face verification and face capture package built with Google ML Kit.

`facetest` provides a ready-to-use face verification experience that guides users through different facial poses and captures their face while performing real-time face detection.

The package can be used for identity verification, KYC onboarding, biometric authentication flows, user registration, and other applications that require face-based verification.

## Features

- Real-time face detection using Google ML Kit.
- Face positioning and alignment guidance.
- Face pose detection.
- Supports multiple facial actions and directions:
  - Look straight at the camera.
  - Look left.
  - Look right.
  - Look up.
  - Look down.
  - Smile.
- Visual instructions to guide users during verification.
- Face capture and verification flow.
- Customizable face capture configuration.
- Custom face verification UI components.
- Progress indication during the verification process.
- Success and error states.
- Optional sound instructions.
- Support for Android and iOS.
- Customizable colors and UI components.

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



IF YOU ENCOUNTER ISSUES WHEN BUILDING THE APP IN RELEASE MODE TRY ADDING THE PROGAUARD RULES
'''
# ML Kit Face Detection uses reflection; R8 strips it in release otherwise.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_common.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
'''
# Installation

Add `facetest` to your Flutter application's `pubspec.yaml`:

```yaml
dependencies:
  facetest: ^1.0.0+1