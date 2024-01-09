# Swoir

![Version](https://img.shields.io/badge/version-0.19.4--1-darkviolet)
[![Noir](https://img.shields.io/badge/Noir-0.19.4-darkviolet)](https://github.com/AztecProtocol/aztec-packages/tree/master/noir)
[![Swift 5](https://img.shields.io/badge/Swift-5-blue.svg)](https://developer.apple.com/swift/)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-green)](https://opensource.org/license/apache-2-0)

Swoir is a Swift package for creating and verifying [Noir](https://noir-lang.org) zero-knowledge proofs.

## Getting Started

### Swift Package Manager

To use `Swoir` in your project, add the following to your `Package.swift` dependencies:

```swift
let package = Package(
    name: "YourSwiftProject",
    // ...
    dependencies: [
        .package(url: "https://github.com/Swoir/Swoir.git", exact: "0.19.4-1")
    ],
    // ...
    targets: [
        .target(name: "YourSwiftProject", dependencies: ["Swoir"])
    ]
)
```

## Usage

```swift
import Swoir

let swoir = Swoir(backend: Swoirenberg.self)
let manifest = Bundle.module.url(forResource: "x_not_eq_y.json", withExtension: nil)!
let circuit = try swoir.createCircuit(manifest: manifest)

let proof = try circuit.prove([ "x": 1, "y": 2 ])
let verified = try circuit.verify(proof)

print(verified ? "Verified!" : "Failed to verify")
```

## Architectures

- iOS with architectures: `arm64`
- macOS with architectures: `x86_64`, `arm64`

## Authors

- [Michael Elliot](https://x.com/michaelelliot)

## Contributing

Contributions are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

Licensed under the Apache-2.0 License. See [LICENSE](./LICENSE) for more information.
