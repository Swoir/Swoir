import XCTest
import Swoir
import SwoirCore
import Swoirenberg

final class SwoirTests: XCTestCase {

    func testProveVerifySuccess_x_not_eq_y() throws {
        let swoir = Swoir(backend: Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "x_not_eq_y.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs = [ "x": 1, "y": 2 ]
        // UltraPlonk
        var proof = try circuit.prove(inputs, proof_type: "plonk")
        var verified = try circuit.verify(proof, proof_type: "plonk")
        XCTAssertTrue(verified, "Failed to verify UltraPlonk proof")
        // Honk
        proof = try circuit.prove(inputs, proof_type: "honk")
        verified = try circuit.verify(proof, proof_type: "honk")
        XCTAssertTrue(verified, "Failed to verify Honk proof")
    }

    func testProveFail_x_not_eq_y() throws {
        let swoir = Swoir(backend: Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "x_not_eq_y.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs = [ "x": 1, "y": 1 ]
        // UltraPlonk
        XCTAssertThrowsError(try circuit.prove(inputs, proof_type: "plonk")) { error in
            XCTAssertEqual(error as? SwoirBackendError, .errorProving("Error generating proof"))
        }
        // Honk
        XCTAssertThrowsError(try circuit.prove(inputs, proof_type: "honk")) { error in
            XCTAssertEqual(error as? SwoirBackendError, .errorProving("Error generating proof"))
        }
    }

    func testProveVerifySuccess_field_array() throws {
        let swoir = Swoir(backend: Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "field_array.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs = [ "x": [1, 2], "y": [1, 3] ]
        // UltraPlonk
        var proof = try circuit.prove(inputs, proof_type: "plonk")
        var verified = try circuit.verify(proof, proof_type: "plonk")
        XCTAssertTrue(verified, "Failed to verify UltraPlonk proof")
        // Honk
        proof = try circuit.prove(inputs, proof_type: "honk")
        verified = try circuit.verify(proof, proof_type: "honk")
        XCTAssertTrue(verified, "Failed to verify Honk proof")
    }

    func testProveVerifySuccess_known_preimage() throws {
        let swoir = Swoir(Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "known_preimage.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs = [
            "preimage": Data("Hello, world!".utf8).map({ $0 as UInt8 }),
            "hash": Data.fromHex("0xb6e16d27ac5ab427a7f68900ac5559ce272dc6c37c82b3e052246c82244c50e4").map({ $0 as UInt8 })
        ]
        // UltraPlonk
        var proof = try circuit.prove(inputs, proof_type: "plonk")
        var verified = try circuit.verify(proof, proof_type: "plonk")
        XCTAssertTrue(verified, "Failed to verify UltraPlonk proof")
        // Honk
        proof = try circuit.prove(inputs, proof_type: "honk")
        verified = try circuit.verify(proof, proof_type: "honk")
        XCTAssertTrue(verified, "Failed to verify Honk proof")
    }

    func testProveVerifySuccess_count_letters() throws {
        let swoir = Swoir(backend: Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "count_letters.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs = [ "words": Data("Hello, world!".utf8).map({ $0 as UInt8 }), "letter": Data("l".utf8)[0] as UInt8, "count": 3 ] as [String: Any]
        // UltraPlonk
        var proof = try circuit.prove(inputs, proof_type: "plonk")
        var verified = try circuit.verify(proof, proof_type: "plonk")
        XCTAssertTrue(verified, "Failed to verify UltraPlonk proof")
        // Honk
        proof = try circuit.prove(inputs, proof_type: "honk")
        verified = try circuit.verify(proof, proof_type: "honk")
        XCTAssertTrue(verified, "Failed to verify Honk proof")
    }

    func testProveVerifySuccess_struct() throws {
        let swoir = Swoir(backend: Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "struct.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs: [String: Any] = [
            "factors": [
                "a": 2,
                "b": 3
            ],
            "result": 6
        ];
        // UltraPlonk
        var proof = try circuit.prove(inputs, proof_type: "plonk")
        var verified = try circuit.verify(proof, proof_type: "plonk")
        XCTAssertTrue(verified, "Failed to verify UltraPlonk proof")
        // Honk
        proof = try circuit.prove(inputs, proof_type: "honk")
        verified = try circuit.verify(proof, proof_type: "honk")
        XCTAssertTrue(verified, "Failed to verify Honk proof")
    }

    func testProveVerifySuccess_string() throws {
        let swoir = Swoir(backend: Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "string.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs = [ 
            "a": "hello", 
            "b": "world", 
            "c" : ["hello", "world", "hello", "world", "hello", "world", "hello", "world", "hello", "world"]
        ] as [String: Any]
        // UltraPlonk
        var proof = try circuit.prove(inputs, proof_type: "plonk")
        var verified = try circuit.verify(proof, proof_type: "plonk")
        XCTAssertTrue(verified, "Failed to verify UltraPlonk proof")
        // Honk
        proof = try circuit.prove(inputs, proof_type: "honk")
        verified = try circuit.verify(proof, proof_type: "honk")
        XCTAssertTrue(verified, "Failed to verify Honk proof")
    }
    
    func testProveVerifySuccess_multi_dimensions_array() throws {
        let swoir = Swoir(backend: Swoirenberg.self)
        let manifest = Bundle.module.url(forResource: "multi_dimensions_array.json", withExtension: nil)!
        let circuit = try swoir.createCircuit(manifest: manifest)
        try circuit.setupSrs()

        let inputs = [
            "a": [        
                [1, 2, 3, 4, 5],
                [6, 7, 8, 9, 10]
            ],
            "b": [
                [11, 12, 13, 14, 15],
                [16, 17, 18, 19, 20]
            ]
        ]
        // UltraPlonk
        var proof = try circuit.prove(inputs, proof_type: "plonk")
        var verified = try circuit.verify(proof, proof_type: "plonk")
        XCTAssertTrue(verified, "Failed to verify UltraPlonk proof")
        // Honk
        proof = try circuit.prove(inputs, proof_type: "honk")
        verified = try circuit.verify(proof, proof_type: "honk")
        XCTAssertTrue(verified, "Failed to verify Honk proof")
    }
}
