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
    public var num_points: UInt32 = 0

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

    public func setupSrs(srs_path: String? = nil, recursive: Bool = false) throws {
        num_points = try backend.setup_srs(bytecode: self.bytecode, srs_path: srs_path, recursive: recursive)
    }

    public func execute(_ inputs: [String: Any]) throws -> [String] {
        let witnessMap = try generateWitnessMap(inputs, self.manifest.abi.parameters)
        let solvedWitness = try backend.execute(bytecode: self.bytecode, witnessMap: witnessMap)
        return solvedWitness
    }

    public func prove(_ inputs: [String: Any], proof_type: String = "honk", recursive: Bool = false) throws -> Proof {
        if num_points == 0 {
            throw SwoirError.srsNotSetup("SRS not setup. Call setupSrs() before proving.")
        }
        let witnessMap = try generateWitnessMap(inputs, self.manifest.abi.parameters)
        let proof = try backend.prove(bytecode: self.bytecode, witnessMap: witnessMap, proof_type: proof_type, recursive: recursive)
        return proof
    }

    public func verify(_ proof: Proof, proof_type: String = "honk") throws -> Bool {
        if num_points == 0 {
            throw SwoirError.srsNotSetup("SRS not setup. Call setupSrs() before verifying.")
        }
        let verified = try backend.verify(proof: proof, proof_type: proof_type)
        return verified
    }

    func inputToWitnessMapValue(_ input: Any) -> WitnessMapValue? {
        if let input = input as? Int            { return WitnessMapValue(input) }
        else if let input = input as? Int8     { return WitnessMapValue(input) }
        else if let input = input as? UInt8   { return WitnessMapValue(input) }
        else if let input = input as? Int16   { return WitnessMapValue(input) }
        else if let input = input as? UInt16 { return WitnessMapValue(input) }
        else if let input = input as? Int32   { return WitnessMapValue(input) }
        else if let input = input as? UInt32 { return WitnessMapValue(input) }
        else if let input = input as? Int64   { return WitnessMapValue(input) }
        else if let input = input as? UInt64 { return WitnessMapValue(input) }
        else if let input = input as? String { return WitnessMapValue(input) }
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
        else if let input = input as? [String] { return input.map { WitnessMapValue($0) } }
        else { return nil }
    }  

    func flattenMultidimensionalArray(_ input: Any) -> [Any] {
        var flattened: [Any] = []
        if let input = input as? [Any] {
            for element in input {
                flattened.append(contentsOf: flattenMultidimensionalArray(element))
            }
        } else {
            flattened.append(input)
        }
        return flattened
    }

    func computeTotalLengthOfArray(_ kind : ABI_ParameterType) -> Int {
        switch kind {
        case .kindArray(_, let length, let type):
            return length * computeTotalLengthOfArray(type)
        case .kindField:
            return 1
        case .kindInteger:
            return 1
        case .kindString(_, let length):
            return length
        case .kindStruct(_, _, let fields):
            return fields.reduce(0) { $0 + computeTotalLengthOfArray($1.type) }
        }
    }

    func generateWitnessMap(_ inputs: [String: Any], _ parameters: [ABI_Parameter]) throws -> [WitnessMapValue] {
        var witnessMap: [WitnessMapValue] = []
        for param in parameters {
            if !inputs.keys.contains(param.name) {
                throw SwoirError.missingInput("Missing input: \(param.name)")
            }
            let input = inputs[param.name]

            switch param.type {
            case .kindArray(_, let length, let type ):
                // Make sure any extradimensions are flattened
                let input = flattenMultidimensionalArray(input!)
                // And then compute the expected length of the flattened array
                let totalLength = computeTotalLengthOfArray(param.type)
                switch type {
                case .kindString(_, let string_length):
                    // Convert each String in the array into a UInt8 array
                    for element in input as! [String] {
                        guard let elementData = element.data(using: .utf8)?.map({ $0 as UInt8 }) else {
                            throw SwoirError.invalidInput("Failed to convert input \(param.name) to UTF-8 data.")
                        }
                        guard let elementData = inputArrayToWitnessMapValue(elementData) else {
                            throw SwoirError.invalidInput("Failed to convert input \(param.name) to WitnessMapValue.")
                        }
                        if elementData.count != string_length {
                            throw SwoirError.invalidInput("Array length mismatch for input \(param.name). Input array length is \(elementData.count) but circuit expects \(length)")
                        }
                        witnessMap.append(contentsOf: elementData)
                    }
                default:
                    guard let inputArray = inputArrayToWitnessMapValue(input as Any) else {
                        throw SwoirError.invalidInput("Invalid array type for input \(param.name).")
                    }
                    if inputArray.count != totalLength {
                        throw SwoirError.invalidInput("Array length mismatch for input \(param.name). Input array length is \(inputArray.count) but circuit expects \(length)")
                    }
                    witnessMap.append(contentsOf: inputArray)
                }
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

            case .kindString(_, let length):
                guard let input = input as? String else {
                    throw SwoirError.invalidInput("Input \(param.name) must be a string.")
                }
                if input.count != length {
                    throw SwoirError.invalidInput("String length mismatch for input \(param.name). Input string length is \(input.count) but circuit expects \(length)")
                }
                guard let input = input.data(using: .utf8)?.map({ $0 as UInt8 }) else {
                    throw SwoirError.invalidInput("Failed to convert input \(param.name) to UTF-8 data.")
                }
                guard let input = inputArrayToWitnessMapValue(input) else {
                    throw SwoirError.invalidInput("Failed to convert input \(param.name) to WitnessMapValue.")
                }
                witnessMap.append(contentsOf: input)

            case .kindStruct(_, _, let fields):
                guard let input = input as? [String: Any] else {
                    throw SwoirError.invalidInput("Input \(param.name) must be a struct.")
                }
                let fieldWitnessMap = try generateWitnessMap(input, fields)
                witnessMap.append(contentsOf: fieldWitnessMap)

            }
        }
        return witnessMap
    }
}
