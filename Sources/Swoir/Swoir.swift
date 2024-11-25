import Foundation
import SwoirCore

public typealias WitnessMapValue = String

public struct CircuitManifest: Codable {
    let bytecode: String
    let abi: ABI
    public let hash: UInt64

    enum CodingKeys: String, CodingKey {
        case bytecode = "bytecode"
        case abi = "abi"
        case hash = "hash"
    }
}

public struct ABI: Codable {
    let parameters: [ABI_Parameter]

    enum CodingKeys: String, CodingKey {
        case parameters = "parameters"
    }
}

public struct ABI_Parameter: Codable {
    let name: String
    let type: ABI_ParameterType
    let visibility: String?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case type = "type"
        case visibility = "visibility"
    }
}

public indirect enum ABI_ParameterType: Codable {
    case kindInteger(kind: String, sign: String, width: Int)
    case kindArray(kind: String, length: Int, type: ABI_ParameterType)
    case kindField(kind: String)
    case kindString(kind: String, length: Int)
    case kindStruct(kind: String, path: String, fields: [ABI_Parameter])

    enum CodingKeys: CodingKey {
        case kind, sign, width, length, type, fields, path
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)
        switch kind {
        case "integer":
            let sign = try container.decode(String.self, forKey: .sign)
            let width = try container.decode(Int.self, forKey: .width)
            self = .kindInteger(kind: kind, sign: sign, width: width)
        case "array":
            let length = try container.decode(Int.self, forKey: .length)
            let type = try container.decode(ABI_ParameterType.self, forKey: .type)
            self = .kindArray(kind: kind, length: length, type: type)
        case "field":
            self = .kindField(kind: kind)
        case "string":
            let length = try container.decode(Int.self, forKey: .length)
            self = .kindString(kind: kind, length: length)
        case "struct":
            let path = try container.decode(String.self, forKey: .path)
            let fields =  try container.decode([ABI_Parameter].self, forKey: .fields)
            self = .kindStruct(kind: kind, path: path, fields: fields)
        default:
            throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: "Unknown kind")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .kindInteger(let kind, let sign, let width):
            try container.encode(kind, forKey: .kind)
            try container.encode(sign, forKey: .sign)
            try container.encode(width, forKey: .width)
        case .kindArray(let kind, let length, let type):
            try container.encode(kind, forKey: .kind)
            try container.encode(length, forKey: .length)
            try container.encode(type, forKey: .type)
        case .kindField(let kind):
            try container.encode(kind, forKey: .kind)
        case .kindString(let kind, let length):
            try container.encode(kind, forKey: .kind)
            try container.encode(length, forKey: .length)
        case .kindStruct(let kind, let path, let fields):
            try container.encode(kind, forKey: .kind)
            try container.encode(fields, forKey: .fields)
            try container.encode(path, forKey: .path)
        }
    }
}

public indirect enum Kind {
    case integer(sign: String, width: Int)
    case field
    case array(length: Int, type: ABI_ParameterType)
    case string(length: Int)
    case structType(fields: [ABI_Parameter])
}

public enum SwoirError: Error {
    case errorLoadingManifest(String)
    case errorParsingManifest(String)
    case circuitNotFound(String)
    case missingInput(String)
    case invalidInput(String)
    case srsNotSetup(String)
    case general(String)
}

public class Swoir {
    public let backend: SwoirBackendProtocol.Type
    public var circuits: [String: Circuit] = [:]

    public init(_ backend: SwoirBackendProtocol.Type) {
        self.backend = backend
    }

    public init(backend: SwoirBackendProtocol.Type) {
        self.backend = backend
    }

    public func createCircuit(manifest url: URL) throws -> Circuit {
        let circuit = try Circuit(backend: self.backend, manifest: url)
        return circuit
    }

    public func createCircuit(manifest data: Data) throws -> Circuit {
        let circuit = try Circuit(backend: self.backend, manifest: data)
        return circuit
    }
}
