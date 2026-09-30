# Vendored Google ML Kit plugins

Local forks of `google_mlkit_commons` 0.13.0 and `google_mlkit_face_detection`
0.15.1. Dart APIs are unchanged.

The pub.dev plugins only ship CocoaPods. Flutter 3.44+ defaults to Swift
Package Manager, and iOS 26 simulators are arm64-only. Google's CocoaPods
binaries exclude simulator arm64, which is why `flutter run` on iPhone 17 Pro
failed with "No Xcode build settings have been found".

These forks add Swift Package Manager manifests and pull native ML Kit from
[google-mlkit-swiftpm](https://github.com/d-date/google-mlkit-swiftpm) 9.0.2,
which includes Apple Silicon simulator slices.
