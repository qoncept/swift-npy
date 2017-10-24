
import Foundation

// https://docs.scipy.org/doc/numpy-dev/neps/npy-format.html

extension Npy {
    public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
    
    public init(data: Data) throws {
        guard let magic = String(data: data.subdata(in: 0..<6), encoding: .ascii) else {
            throw NpyLoaderError.ParseFailed(message: "Can't parse prefix")
        }
        guard magic == MAGIC_PREFIX else {
            throw NpyLoaderError.ParseFailed(message: "Invalid prefix: \(magic)")
        }
        
        let major = data[6]
        guard major == 1 || major == 2 else {
            throw NpyLoaderError.ParseFailed(message: "Invalid major version: \(major)")
        }
        
        let minor = data[7]
        guard minor == 0 else {
            throw NpyLoaderError.ParseFailed(message: "Invalid minor version: \(minor)")
        }
        
        let headerLen: Int
        let rest: Data
        switch major {
        case 1:
            let tmp = Data(data[8...9]).withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                ptr.withMemoryRebound(to: UInt16.self, capacity: 1) {
                    UInt16(littleEndian: $0.pointee)
                }
            }
            headerLen = Int(tmp)
            rest = data.subdata(in: 10..<data.count)
        case 2:
            let tmp = Data(data[8...11]).withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                ptr.withMemoryRebound(to: UInt32.self, capacity: 1) {
                    UInt32(littleEndian: $0.pointee)
                }
            }
            headerLen = Int(tmp)
            rest = data.subdata(in: 12..<data.count)
        default:
            fatalError("Never happens.")
        }
        
        let headerData = rest.subdata(in: 0..<headerLen)
        let header = try parseHeader(headerData)
        
        let elemData = rest.subdata(in: headerLen..<rest.count)
        
        self.init(header: header, elementsData: elemData)
    }
}

public enum NpyLoaderError: Error {
    case ParseFailed(message: String)
    case TypeMismatch(message: String)
}

protocol MultiByteUInt {
    init(bigEndian: Self)
    init(littleEndian: Self)
}
extension UInt16: MultiByteUInt {}
extension UInt32: MultiByteUInt {}
extension UInt64: MultiByteUInt {}

func loadUInts<T: MultiByteUInt>(data: Data, count: Int, endian: Endian) -> [T] {
    
    switch endian {
    case .host:
        let uints = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: T.self, capacity: count) { ptr2 in
                [T](UnsafeBufferPointer(start: ptr2, count: count))
            }
        }
        return uints
    case .big:
        return data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: T.self, capacity: count) { ptr2 in
                (0..<count).map { T(bigEndian: ptr2.advanced(by: $0).pointee) }
            }
        }
    case .little:
        return data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: T.self, capacity: count) { ptr2 in
                (0..<count).map { T(littleEndian: ptr2.advanced(by: $0).pointee) }
            }
        }
    case .na:
        fatalError("Invalid byteorder.")
    }
}

func loadUInt8s(data: Data, count: Int) -> [UInt8] {
    let uints = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
        [UInt8](UnsafeBufferPointer(start: ptr, count: count))
    }
    return uints
}
