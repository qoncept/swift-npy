
import Foundation

public func load<T: DataType>(contentsOf url: URL) throws -> NpyData<T> {
    let data = try Data(contentsOf: url)
    return try load(data: data)
}

public func load<T: DataType>(data: Data) throws -> NpyData<T> {
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
    
    try checkType(type: T.self, dataType: header.dataType)
    
    let elemCount = header.shape.reduce(1, *)
    let elemData = rest.subdata(in: headerLen..<rest.count)
    
    let elements: [T] = loadElements(data: elemData,
                                     count: elemCount,
                                     dataType: header.dataType,
                                     isLittleEndian: header.isLittleEndian)
    
    return NpyData(shape: header.shape, elements: elements, isFortrnOrder: header.isFortranOrder)
}

public enum NpyLoaderError: Error {
    case ParseFailed(message: String)
    case TypeMismatch(message: String)
}

private let MAGIC_PREFIX = "\u{93}NUMPY"

private enum NumpyDataType: String {
    case bool = "b1"
    
    case uint8 = "u1"
    case uint16 = "u2"
    case uint32 = "u4"
    case uint64 = "u8"
    
    case int8 = "i1"
    case int16 = "i2"
    case int32 = "i4"
    case int64 = "i8"
    
    case float32 = "f4"
    case float64 = "f8"
    
    static var all: [NumpyDataType] {
        return [.bool,
                .uint8, .uint16, .uint32, .uint64,
                .int8, .int16, .int32, .int64,
                .float32, .float64]
    }
}

private struct NumpyHeader {
    let shape: [Int]
    let dataType: NumpyDataType
    let isLittleEndian: Bool
    let isFortranOrder: Bool
    let descr: String
}

private func parseHeader(_ data: Data) throws -> NumpyHeader {
    
    guard let str = String(data: data, encoding: .ascii) else {
        throw NpyLoaderError.ParseFailed(message: "Failed to load header")
    }
    
    let descr: String
    let isLittleEndian: Bool
    let dataType: NumpyDataType
    let isFortranOrder: Bool
    do {
        let separate = str.components(separatedBy: CharacterSet(charactersIn: ", ")).filter { !$0.isEmpty }
        
        guard let descrIndex = separate.index(where: { $0.contains("descr") }) else {
            throw NpyLoaderError.ParseFailed(message: "Header does not contain the key 'descr'")
        }
        descr = separate[descrIndex + 1]
        
        isLittleEndian = descr.contains("<") || descr.contains("|")
        
        guard let dt = NumpyDataType.all.filter({ descr.contains($0.rawValue) }).first else {
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
    
    return NumpyHeader(shape: shape,
                       dataType: dataType,
                       isLittleEndian: isLittleEndian,
                       isFortranOrder: isFortranOrder,
                       descr: descr)
}

private func checkType<T>(type: T.Type, dataType: NumpyDataType) throws {
    switch (type, dataType) {
    case (is Bool.Type, .bool):
        break
    case (is UInt.Type, .uint8), (is UInt.Type, .uint16), (is UInt.Type, .uint32), (is UInt.Type, .uint64):
        break
    case (is UInt8.Type, .uint8):
        break
    case (is UInt16.Type, .uint16):
        break
    case (is UInt32.Type, .uint32):
        break
    case (is UInt64.Type, .uint64):
        break
    case (is Int.Type, .int8), (is Int.Type, .int16), (is Int.Type, .int32), (is Int.Type, .int64):
        break
    case (is Int8.Type, .int8):
        break
    case (is Int16.Type, .int16):
        break
    case (is Int32.Type, .int32):
        break
    case (is Int64.Type, .int64):
        break
    case (is Float.Type, .float32):
        break
    case (is Double.Type, .float64):
        break
    default:
        throw NpyLoaderError.TypeMismatch(message: "\(type) and \(dataType) are incompatible.")
    }
}

private func loadElements<T>(data: Data, count: Int, dataType: NumpyDataType, isLittleEndian: Bool) -> [T] {
    
    switch dataType {
    case .bool:
        let uints: [UInt8] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        return uints.map { $0 != 0 } as! [T]
    case .uint8:
        let uints: [UInt8] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is UInt.Type {
            return uints.map { UInt($0) } as! [T]
        } else {
            return uints as! [T]
        }
    case .uint16:
        let uints: [UInt16] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is UInt.Type {
            return uints.map { UInt($0) } as! [T]
        } else {
            return uints as! [T]
        }
    case .uint32:
        let uints: [UInt32] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is UInt.Type {
            return uints.map { UInt($0) } as! [T]
        } else {
            return uints as! [T]
        }
    case .uint64:
        let uints: [UInt64] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is UInt.Type {
            return uints.map { UInt($0) } as! [T]
        } else {
            return uints as! [T]
        }
    case .int8:
        let uints: [UInt8] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is Int.Type {
            return uints.map { Int(Int8(bitPattern: $0)) } as! [T]
        } else {
            return uints.map { Int8(bitPattern: $0) } as! [T]
        }
    case .int16:
        let uints: [UInt16] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is Int.Type {
            return uints.map { Int(Int16(bitPattern: $0)) } as! [T]
        } else {
            return uints.map { Int16(bitPattern: $0) } as! [T]
        }
    case .int32:
        let uints: [UInt32] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is Int.Type {
            return uints.map { Int(Int32(bitPattern: $0)) } as! [T]
        } else {
            return uints.map { Int32(bitPattern: $0) } as! [T]
        }
    case .int64:
        let uints: [UInt64] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        if T.self is Int.Type {
            return uints.map { Int(Int64(bitPattern: $0)) } as! [T]
        } else {
            return uints.map { Int64(bitPattern: $0) } as! [T]
        }
    case .float32:
        let uints: [UInt32] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        return uints.map { Float(bitPattern: $0) } as! [T]
    case .float64:
        let uints: [UInt64] = loadUInts(data: data, count: count, isLittleEndian: isLittleEndian)
        return uints.map { Double(bitPattern: $0) } as! [T]
    }
}


protocol UIntProtocol {}
extension UInt8: UIntProtocol {}
extension UInt16: UIntProtocol {}
extension UInt32: UIntProtocol {}
extension UInt64: UIntProtocol {}

private func loadUInts<T: UIntProtocol>(data: Data, count: Int, isLittleEndian: Bool) -> [T] {
    if isLittleEndian || T.self is UInt8.Type {
        let uints = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: T.self, capacity: count) { ptr2 in
                [T](UnsafeBufferPointer(start: ptr2, count: count))
            }
        }
        return uints
    } else {
        switch T.self {
        case is UInt16.Type:
            return data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                ptr.withMemoryRebound(to: UInt16.self, capacity: count) { ptr2 in
                    (0..<count).map { UInt16(bigEndian: ptr2.advanced(by: $0).pointee) }
                } as! [T]
            }
        case is UInt32.Type:
            return data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                ptr.withMemoryRebound(to: UInt32.self, capacity: count) { ptr2 in
                    (0..<count).map { UInt32(bigEndian: ptr2.advanced(by: $0).pointee) }
                } as! [T]
            }
        case is UInt64.Type:
            return data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                ptr.withMemoryRebound(to: UInt64.self, capacity: count) { ptr2 in
                    (0..<count).map { UInt64(bigEndian: ptr2.advanced(by: $0).pointee) }
                } as! [T]
            }
        default:
            fatalError()
        }
    }
}








