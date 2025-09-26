// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BLEMiddleware",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "BLEMiddleware",
            targets: ["BLEMiddleware"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BLEMiddleware",
            dependencies: []),
        .testTarget(
            name: "BLEMiddlewareTests",
            dependencies: ["BLEMiddleware"]),
    ]
)