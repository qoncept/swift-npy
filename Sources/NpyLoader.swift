
import Foundation

public func load<T: DataType>(contentsOf url: URL) throws -> (shape: [Int], elements: [T]) {
    let data = try Data(contentsOf: url)
    return try load(npyData: data)
}

public func load<T: DataType>(npyData: Data) throws -> (shape: [Int], elements: [T]) {
    guard let magic = String(data: npyData.subdata(in: 0..<6), encoding: .ascii) else {
        throw NumpyArrayLoaderError.ParseFailed(message: "Can't parse prefix")
    }
    guard magic == MAGIC_PREFIX else {
        throw NumpyArrayLoaderError.ParseFailed(message: "Invalid prefix: \(magic)")
    }
    
    let major = npyData[6]
    guard major == 1 || major == 2 else {
        throw NumpyArrayLoaderError.ParseFailed(message: "Invalid major version: \(major)")
    }
    
    let minor = npyData[7]
    guard minor == 0 else {
        throw NumpyArrayLoaderError.ParseFailed(message: "Invalid minor version: \(minor)")
    }
    
    let headerLen: Int
    let rest: Data
    switch major {
    case 1:
        let tmp = Data(npyData[8...9]).withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: UInt16.self, capacity: 1) {
                UInt16(littleEndian: $0.pointee)
            }
        }
        headerLen = Int(tmp)
        rest = npyData.subdata(in: 10..<npyData.count)
    case 2:
        let tmp = Data(npyData[8...11]).withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: UInt32.self, capacity: 1) {
                UInt32(littleEndian: $0.pointee)
            }
        }
        headerLen = Int(tmp)
        rest = npyData.subdata(in: 12..<npyData.count)
    default:
        fatalError("Never happens.")
    }
    
    let headerData = rest.subdata(in: 0..<headerLen)
    let header = try parseHeader(headerData)
    
    try checkType(type: T.self, dataType: header.dataType)
    
    let elemCount = header.shape.reduce(1, *)
    let elemData = rest.subdata(in: headerLen..<rest.count)
    
    let elemPtr = UnsafeMutablePointer<T>.allocate(capacity: elemCount)
    defer { elemPtr.deallocate(capacity: elemCount) }
    
    switch (header.dataType, header.isLittleEndian) {
    case (.float32, true):
        let elements = elemData.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: Float32.self, capacity: elemCount) { ptr2 in
                (0..<elemCount).map { Float(ptr2.advanced(by: $0).pointee) }
            }
        }
        memcpy(elemPtr, elements, elemCount*MemoryLayout<Float>.size)
    case (.float32, false):
        let uints = elemData.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: UInt32.self, capacity: elemCount) { ptr2 in
                (0..<elemCount).map { UInt32(bigEndian: ptr2.advanced(by: $0).pointee) }
            }
        }
        let elements = uints.map { Float(Float32(bitPattern: $0)) }
        memcpy(elemPtr, elements, elemCount*MemoryLayout<Float>.size)
    case (.float64, true):
        let elements = elemData.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: Float64.self, capacity: elemCount) { ptr2 in
                (0..<elemCount).map { Double(ptr2.advanced(by: $0).pointee) }
            }
        }
        memcpy(elemPtr, elements, elemCount*MemoryLayout<Double>.size)
    case (.float64, false):
        let uints = elemData.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            ptr.withMemoryRebound(to: UInt64.self, capacity: elemCount) { ptr2 in
                (0..<elemCount).map { UInt64(bigEndian: ptr2.advanced(by: $0).pointee) }
            }
        }
        let elements = uints.map { Double(Float64(bitPattern: $0)) }
        memcpy(elemPtr, elements, elemCount*MemoryLayout<Double>.size)
    }
    
    let elements = [T](UnsafeBufferPointer(start: elemPtr, count: elemCount))
    
    return (header.shape, elements)
}

public enum NumpyArrayLoaderError: Error {
    case ParseFailed(message: String)
    case TypeMismatch(message: String)
}

private let MAGIC_PREFIX = "\u{93}NUMPY"

private struct NumpyHeader {
    let shape: [Int]
    let dataType: NumpyDataType
    let isLittleEndian: Bool
    let isFortranOrder: Bool
    let descr: String
}

private func parseHeader(_ data: Data) throws -> NumpyHeader {
    
    guard let str = String(data: data, encoding: .ascii) else {
        throw NumpyArrayLoaderError.ParseFailed(message: "Failed to load header")
    }
    
    let descr: String
    let isLittleEndian: Bool
    let dataType: NumpyDataType
    let isFortranOrder: Bool
    do {
        let separate = str.components(separatedBy: CharacterSet(charactersIn: ", ")).filter { !$0.isEmpty }
        
        guard let descrIndex = separate.index(where: { $0.contains("descr") }) else {
            throw NumpyArrayLoaderError.ParseFailed(message: "Header does not contain the key 'descr'")
        }
        descr = separate[descrIndex + 1]
        
        isLittleEndian = descr.contains("<") || descr.contains("|")
        
        guard let dt = NumpyDataType.all.filter({ descr.contains($0.rawValue) }).first else {
            fatalError("Unsupported dtype: \(descr)")
        }
        dataType = dt
        
        guard let fortranIndex = separate.index(where: { $0.contains("fortran_order") }) else {
            throw NumpyArrayLoaderError.ParseFailed(message: "Header does not contain the key 'fortran_order'")
        }
        
        isFortranOrder = separate[fortranIndex+1].contains("True")
        
        guard !isFortranOrder else {
            fatalError("\"fortran_order\" must be False.")
        }
    }
    
    var shape: [Int] = []
    do {
        guard let left = str.range(of: "("),
            let right = str.range(of: ")") else {
                throw NumpyArrayLoaderError.ParseFailed(message: "Shape not found in header.")
        }
        
        let substr = str.substring(with: left.upperBound..<right.lowerBound)
        
        let strs = substr.replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
            .filter { !$0.isEmpty }
        for s in strs {
            guard let i = Int(s) else {
                throw NumpyArrayLoaderError.ParseFailed(message: "Shape contains invalid integer: \(s)")
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
    case (is Float.Type, .float32):
        break
    case (is Double.Type, .float64):
        break
    default:
        throw NumpyArrayLoaderError.TypeMismatch(message: "\(type) and \(dataType) are incompatible.")
    }
}

private enum NumpyDataType: String {
    case float32 = "f4"
    case float64 = "f8"
    
    static var all: [NumpyDataType] {
        return [.float32, .float64]
    }
}
