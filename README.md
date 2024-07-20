# Swoir

![Version](https://img.shields.io/badge/version-0.30.0--8-darkviolet)
[![Noir](https://img.shields.io/badge/Noir-0.30.0--8-darkviolet)](https://github.com/AztecProtocol/aztec-packages/tree/master/noir)
[![Swift 5](https://img.shields.io/badge/Swift-5-blue.svg)](https://developer.apple.com/swift/)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-green)](https://opensource.org/license/apache-2-0)

Swoir is a Swift package for creating and verifying [Noir](https://noir-lang.org) zero-knowledge proofs.

## Getting Started

### Swift Package Manager

To use `Swoir` in your project, add the following to your `Package.swift` dependencies:

```swift
let package = Package(
    name: "YourSwiftProject",
    platforms: [ .macOS(.v10_15), .iOS(.v14) ],
    // ...
    dependencies: [
        .package(url: "https://github.com/Swoir/Swoir.git", exact: "0.30.0-4")
    ],
    // ...
    targets: [
        .target(name: "YourSwiftProject", dependencies: ["Swoir"])
    ]
)
```

## Usage

```swift
import Foundation
import Swoir
import Swoirenberg

let swoir = Swoir(backend: Swoirenberg.self)
let manifest = URL(fileURLWithPath: "x_not_eq_y.json")
let circuit = try swoir.createCircuit(manifest: manifest)

let proof = try circuit.prove([ "x": 1, "y": 2 ])
let verified = try circuit.verify(proof)

print(verified ? "Verified!" : "Failed to verify")
```

Ensure [x_not_eq_y.json](./Tests/SwoirTests/Fixtures/contracts/x_not_eq_y/target/x_not_eq_y.json) exists in the project root.

## Architectures

- iOS with architectures: `arm64`
- macOS with architectures: `arm64`

## Authors

- [Michael Elliot](https://x.com/michaelelliot)

## Contributing

Contributions are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

Licensed under the Apache-2.0 License. See [LICENSE](./LICENSE) for more information.
