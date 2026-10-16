// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Basil",
    products: [
        .executable(name: "Basil", targets: ["Basil"])
    ],
    targets: [
        .executableTarget(
            name: "Basil"
        )
    ]
)
