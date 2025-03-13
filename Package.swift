// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Swoir",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Swoir",
            targets: ["Swoir"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swoir/SwoirCore.git", exact: "0.8.0"),
        .package(url: "https://github.com/Swoir/Swoirenberg.git", exact: "1.0.0-beta.3-3"),
    ],
    targets: [
        .target(
            name: "Swoir",
            dependencies: ["SwoirCore", "Swoirenberg"]),
        .testTarget(
            name: "SwoirTests",
            dependencies: ["Swoir"],
            exclude: [
                "Fixtures/contracts/x_not_eq_y/Nargo.toml",
                "Fixtures/contracts/x_not_eq_y/src/main.nr",
                "Fixtures/contracts/field_array/Nargo.toml",
                "Fixtures/contracts/field_array/src/main.nr",
                "Fixtures/contracts/known_preimage/Nargo.toml",
                "Fixtures/contracts/known_preimage/src/main.nr",
                "Fixtures/contracts/count_letters/Nargo.toml",
                "Fixtures/contracts/count_letters/src/main.nr",
                "Fixtures/contracts/struct/Nargo.toml",
                "Fixtures/contracts/struct/src/main.nr",
                "Fixtures/contracts/string/src/string.nr",
                "Fixtures/contracts/string/Nargo.toml",
                "Fixtures/contracts/multi-dimensions-array/src/main.nr",
                "Fixtures/contracts/multi-dimensions-array/Nargo.toml",],
            resources: [
                .process("Fixtures/contracts/x_not_eq_y/target"),
                .process("Fixtures/contracts/field_array/target"),
                .process("Fixtures/contracts/known_preimage/target"),
                .process("Fixtures/contracts/count_letters/target"),
                .process("Fixtures/contracts/struct/target"),
                .process("Fixtures/contracts/string/target"),
                .process("Fixtures/contracts/multi-dimensions-array/target"),]),
    ]
)
