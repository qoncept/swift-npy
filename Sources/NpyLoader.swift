
import Foundation

public func load(contentsOf url: URL) throws -> Npy {
    let data = try Data(contentsOf: url)
    return try load(data: data)
}

public func load(data: Data) throws -> Npy {
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
    
    return Npy(header: header, elementsData: elemData)
}

public enum NpyLoaderError: Error {
    case ParseFailed(message: String)
    case TypeMismatch(message: String)
}

private let MAGIC_PREFIX = "\u{93}NUMPY"

private func parseHeader(_ data: Data) throws -> NpyHeader {
    
    guard let str = String(data: data, encoding: .ascii) else {
        throw NpyLoaderError.ParseFailed(message: "Failed to load header")
    }
    
    let descr: String
    let isLittleEndian: Bool
    let dataType: DataType
    let isFortranOrder: Bool
    do {
        let separate = str.components(separatedBy: CharacterSet(charactersIn: ", ")).filter { !$0.isEmpty }
        
        guard let descrIndex = separate.index(where: { $0.contains("descr") }) else {
            throw NpyLoaderError.ParseFailed(message: "Header does not contain the key 'descr'")
        }
        descr = separate[descrIndex + 1]
        
        isLittleEndian = descr.contains("<") || descr.contains("|")
        
        guard let dt = DataType.all.filter({ descr.contains($0.rawValue) }).first else {
            fatalError("Unsupported dtype: \(descr)")
        }
        dataType = dt
        
        guard let fortranIndex = separate.index(where: { $0.contains("fortran_order") }) else {
            throw NpyLoaderError.ParseFailed(message: "Header does not contain the key 'fortran_order'")
        }
        
        isFortranOrder = separate[fortranIndex+1].contains("True")
    }
    
    var shape: [Int] = []
    do {
        guard let left = str.range(of: "("),
            let right = str.range(of: ")") else {
                throw NpyLoaderError.ParseFailed(message: "Shape not found in header.")
        }
        
        let substr = str.substring(with: left.upperBound..<right.lowerBound)
        
        let strs = substr.replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
            .filter { !$0.isEmpty }
        for s in strs {
            guard let i = Int(s) else {
                throw NpyLoaderError.ParseFailed(message: "Shape contains invalid integer: \(s)")
            }
            shape.append(i)
        }
    }
    
    return NpyHeader(shape: shape,
                       dataType: dataType,
                       isLittleEndian: isLittleEndian,
                       isFortranOrder: isFortranOrder,
                       descr: descr)
}

protocol MultiByteUInt {
    init(bigEndian: Self)
}
extension UInt16: MultiByteUInt {}
extension UInt32: MultiByteUInt {}
extension UInt64: MultiByteUInt {}

func loadUInts<T: MultiByteUInt>(data: Data, count: Int, isLittleEndian: Bool) -> [T] {
    if isLittleEndian || T.self is UInt8.Type {
        let uints = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: T.self, capacity: count) { ptr2 in
                [T](UnsafeBufferPointer(start: ptr2, count: count))
            }
        }
        return uints
    } else {
        return data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: T.self, capacity: count) { ptr2 in
                (0..<count).map { T(bigEndian: ptr2.advanced(by: $0).pointee) }
            }
        }
    }
}

func loadUInt8s(data: Data, count: Int) -> [UInt8] {
    let uints = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
        [UInt8](UnsafeBufferPointer(start: ptr, count: count))
    }
    return uints
}
