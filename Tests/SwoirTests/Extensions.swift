import Foundation

extension Data {
    static func fromHex(_ hexString: String) -> Data {
        let cleanedHexString = hexString.hasPrefix("0x") ? String(hexString.dropFirst(2)) : hexString
        guard cleanedHexString.count % 2 == 0, !cleanedHexString.isEmpty else { return Data() }
        var data = Data()
        for i in stride(from: 0, to: cleanedHexString.count, by: 2) {
            let start = cleanedHexString.index(cleanedHexString.startIndex, offsetBy: i)
            let end = cleanedHexString.index(start, offsetBy: 2)
            let byteString = cleanedHexString[start..<end]
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            } else {
                return Data()
            }
        }
        return data
    }
}
