
import Foundation

public func save(npy: Npy, to url: URL) throws {
    let data = format(npy: npy)
    try data.write(to: url)
}

public func format(npy: Npy) -> Data {
    
    var data = Data()
    
    let magic = MAGIC_PREFIX.unicodeScalars.map { c -> UInt8 in
        return UInt8(c.value)
    }
    
    data.append(contentsOf: magic)
    
    let header = encodeHeader(npy.header)
    
    if header.count > 65535 {
        // v2
        data.append(0x02)
        data.append(0x00)
    } else {
        // v1
        data.append(0x01)
        data.append(0x00)
    }
    
    var headerLen = UInt16(header.count)
    withUnsafePointer(to: &headerLen) { p in
        p.withMemoryRebound(to: UInt8.self, capacity: 2) {
            data.append($0, count: MemoryLayout<UInt16>.size)
        }
    }
    
    data.append(header)
    data.append(npy.elementsData)
    
    return data
}
