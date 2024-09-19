import CoreFoundation
import Foundation

extension Npy {
    public func save(to url: URL) throws {
        let data = self.format()
        try data.write(to: url)
    }
    
    public func format() -> Data {
        var data = Data()
        
        data.append(contentsOf: MAGIC_PREFIX)
        
        let header = encodeHeader(self.header)
        
        if header.count > 65535 {
            // v2
            data.append(0x02)
            data.append(0x00)
            var headerLen = UInt32(header.count).littleEndian
            withUnsafePointer(to: &headerLen) { p in
                p.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt32>.size) {
                    data.append($0, count: MemoryLayout<UInt32>.size)
                }
            }
        } else {
            // v1
            data.append(0x01)
            data.append(0x00)
            var headerLen = UInt16(header.count).littleEndian
            withUnsafePointer(to: &headerLen) { p in
                p.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt16>.size) {
                    data.append($0, count: MemoryLayout<UInt16>.size)
                }
            }
        }
        
        
        data.append(header)
        data.append(self.elementsData)
        
        return data
    }
}

func toData(elements: [UInt16], endian: Endian) -> Data {
    let uints: [UInt16]
    switch endian {
    case .host:
        uints = elements
    case .big:
        uints = elements.map(CFSwapInt16HostToBig)
    case .little:
        uints =  elements.map(CFSwapInt16HostToLittle)
    case .na:
        fatalError("Invalid byteorder.")
    }
    let count = MemoryLayout<UInt16>.size * elements.count
    return Data(bytes: uints, count: count)
}

func toData(elements: [UInt32], endian: Endian) -> Data {
    let uints: [UInt32]
    switch endian {
    case .host:
        uints = elements
    case .big:
        uints = elements.map(CFSwapInt32HostToBig)
    case .little:
        uints =  elements.map(CFSwapInt32HostToLittle)
    case .na:
        fatalError("Invalid byteorder.")
    }
    let count = MemoryLayout<UInt32>.size * elements.count
    return Data(bytes: uints, count: count)
}

func toData(elements: [UInt64], endian: Endian) -> Data {
    let uints: [UInt64]
    switch endian {
    case .host:
        uints = elements
    case .big:
        uints = elements.map(CFSwapInt64HostToBig)
    case .little:
        uints =  elements.map(CFSwapInt64HostToLittle)
    case .na:
        fatalError("Invalid byteorder.")
    }
    let count = MemoryLayout<UInt64>.size * elements.count
    return Data(bytes: uints, count: count)
}
