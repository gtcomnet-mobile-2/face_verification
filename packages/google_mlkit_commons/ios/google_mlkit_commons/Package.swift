// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "google_mlkit_commons",
    platforms: [
        .iOS("15.5")
    ],
    products: [
        .library(name: "google-mlkit-commons", targets: ["google_mlkit_commons"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "9.0.2"),
    ],
    targets: [
        .target(
            name: "google_mlkit_commons",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                // google-mlkit-swiftpm does not export MLKitVision as its own product.
                .product(name: "MLKitFaceDetection", package: "google-mlkit-swiftpm"),
            ]
        )
    ]
)
