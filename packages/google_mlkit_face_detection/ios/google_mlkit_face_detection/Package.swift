// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_face_detection",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(name: "google-mlkit-face-detection", targets: ["google_mlkit_face_detection"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(name: "google_mlkit_commons", path: "../google_mlkit_commons"),
        .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "9.0.2"),
    ],
    targets: [
        .target(
            name: "google_mlkit_face_detection",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "google-mlkit-commons", package: "google_mlkit_commons"),
                .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
            ],
            resources: [
                .copy("Resources/GoogleMVFaceDetectorResources.bundle"),
            ]
        )
    ]
)
