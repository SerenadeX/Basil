// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Basil",
    products: [
        .executable(name: "Basil", targets: ["Basil"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.8.2"),
    ],
    targets: [
        .executableTarget(
            name: "Basil",
            dependencies: [
                .product(name: "ArgumentParser",
                         package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "BasilTests",
            dependencies: ["Basil"]
        )
    ]
)
