import Foundation
import SwoirCore

func parseCircuit(data: Data) throws -> CircuitManifest {
    do {
        return try JSONDecoder().decode(CircuitManifest.self, from: data)
    } catch {
        throw SwoirError.errorParsingManifest(error.localizedDescription)
    }
}

public class Circuit {
    public let backend: SwoirBackendProtocol.Type
    public var manifest: CircuitManifest
    public var manifestData: Data
    public var manifestUrl: URL?
    public var bytecode: Data

    public convenience init(backend: SwoirBackendProtocol.Type, manifest: Data) throws {
        do {
            try self.init(backend: backend, manifestData: manifest)
        } catch {
            throw SwoirError.errorLoadingManifest(error.localizedDescription)
        }
    }
    public convenience init(backend: SwoirBackendProtocol.Type, manifest: URL) throws {
        do {
            let data = try Data(contentsOf: manifest)
            try self.init(backend: backend, manifestData: data)
            self.manifestUrl = manifest
        } catch {
            throw SwoirError.errorLoadingManifest(error.localizedDescription)
        }
    }
    public init(backend: SwoirBackendProtocol.Type, manifestData: Data) throws {
        self.backend = backend
        self.manifest = try parseCircuit(data: manifestData)
        self.manifestData = manifestData
        guard let bytecode = Data(base64Encoded: manifest.bytecode) else {
            throw SwoirError.errorLoadingManifest("Invalid base64 ACIR bytecode in manifest")
        }
        self.bytecode = bytecode
    }

    public func prove(_ inputs: [String: Any]) throws -> Proof {
        let witnessMap = try generateWitnessMap(inputs)
        let proof = try backend.prove(bytecode: self.bytecode, witnessMap: witnessMap)
        return proof
    }

    public func verify(_ proof: Proof) throws -> Bool {
        let verified = try backend.verify(bytecode: self.bytecode, proof: proof)
        return verified
    }

    func inputToWitnessMapValue(_ input: Any) -> WitnessMapValue? {
        if let input = input as? Int         { return WitnessMapValue(input) }
        else if let input = input as? Int8   { return WitnessMapValue(input) }
        else if let input = input as? UInt8  { return WitnessMapValue(input) }
        else if let input = input as? Int16  { return WitnessMapValue(input) }
        else if let input = input as? UInt16 { return WitnessMapValue(input) }
        else if let input = input as? Int32  { return WitnessMapValue(input) }
        else if let input = input as? UInt32 { return WitnessMapValue(input) }
        else if let input = input as? Int64  { return WitnessMapValue(input) }
        else if let input = input as? UInt64 { return WitnessMapValue(input) }
        else { return nil }
    }

    func inputArrayToWitnessMapValue(_ input: Any) -> [WitnessMapValue]? {
        if let input = input as? [Int]         { return input.map { WitnessMapValue($0) } }
        else if let input = input as? Data     { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [Int8]   { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [UInt8]  { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [Int16]  { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [UInt16] { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [Int32]  { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [UInt32] { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [Int64]  { return input.map { WitnessMapValue($0) } }
        else if let input = input as? [UInt64] { return input.map { WitnessMapValue($0) } }
        else { return nil }
    }

    func generateWitnessMap(_ inputs: [String: Any]) throws -> [WitnessMapValue] {
        var witnessMap: [WitnessMapValue] = []
        for param in self.manifest.abi.parameters {
            if !inputs.keys.contains(param.name) {
                throw SwoirError.missingInput("Missing input: \(param.name)")
            }
            let input = inputs[param.name]

            switch param.type {
            case .kindArray(_, let length, _):
                guard let inputArray = inputArrayToWitnessMapValue(input as Any) else {
                    throw SwoirError.invalidInput("Invalid array type for input \(param.name).")
                }
                if inputArray.count != length {
                    throw SwoirError.invalidInput("Array length mismatch for input \(param.name). Input array length is \(inputArray.count) but circuit expects \(length)")
                }
                witnessMap.append(contentsOf: inputArray)

            case .kindField:
                guard let input = inputToWitnessMapValue(input as Any) else {
                    throw SwoirError.invalidInput("Input \(param.name) must be an integer.")
                }
                witnessMap.append(input)

            case .kindInteger:
                guard let input = inputToWitnessMapValue(input as Any) else {
                    throw SwoirError.invalidInput("Input \(param.name) must be an integer.")
                }
                witnessMap.append(input)
            }
        }
        return witnessMap
    }
}
