import Foundation

public struct Npy {
    
    private let header: NpyHeader
    private let elementsData: Data
    
    public var shape: [Int] {
        return header.shape
    }
    
    var elementsCount: Int {
        return shape.reduce(1, *)
    }
    
    public var dataType: NumpyDataType {
        return header.dataType
    }
    
    var isLittleEndian: Bool {
        return header.isLittleEndian
    }
    
    public var isFortranOrder: Bool {
        return header.isFortranOrder
    }
    
    init(header: NpyHeader, elementsData: Data) {
        self.elementsData = elementsData
        self.header = header
    }
    
    public func getElements() -> [Bool] {
        precondition(dataType == .bool)
        let uints: [UInt8] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { $0 != 0 }
    }
    
    public func getElements() -> [UInt] {
        switch dataType {
        case .uint8:
            let uints: [UInt8] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { UInt($0) }
        case .uint16:
            let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { UInt($0) }
        case .uint32:
            let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { UInt($0) }
        case .uint64:
            let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { UInt($0) }
        default:
            preconditionFailure()
        }
    }
    
    public func getElements() -> [UInt8] {
        precondition(dataType == .uint8)
        let uints: [UInt8] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints
    }
    
    public func getElements() -> [UInt16] {
        precondition(dataType == .uint16)
        let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints
    }
    
    public func getElements() -> [UInt32] {
        precondition(dataType == .uint32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints
    }
    
    public func getElements() -> [UInt64] {
        precondition(dataType == .uint64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints
    }
    
    public func getElements() -> [Int] {
        switch dataType {
        case .int8:
            let uints: [UInt8] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { Int(Int8(bitPattern: $0)) }
        case .int16:
            let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { Int(Int16(bitPattern: $0)) }
        case .int32:
            let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { Int(Int32(bitPattern: $0)) }
        case .int64:
            let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
            return uints.map { Int(Int64(bitPattern: $0)) }
        default:
            preconditionFailure()
        }
    }
    
    public func getElements() -> [Int8] {
        precondition(dataType == .int8)
        let uints: [UInt8] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Int8(bitPattern: $0) }
    }
    
    public func getElements() -> [Int16] {
        precondition(dataType == .int16)
        let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Int16(bitPattern: $0) }
    }
    
    public func getElements() -> [Int32] {
        precondition(dataType == .int32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Int32(bitPattern: $0) }
    }
    
    public func getElements() -> [Int64] {
        precondition(dataType == .int64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Int64(bitPattern: $0) }
    }
    
    public func getElements() -> [Float] {
        precondition(dataType == .float32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Float(bitPattern: $0) }
    }
    
    public func getElements() -> [Double] {
        precondition(dataType == .float64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Double(bitPattern: $0) }
    }
}

struct NpyHeader {
    let shape: [Int]
    let dataType: NumpyDataType
    let isLittleEndian: Bool
    let isFortranOrder: Bool
    let descr: String
}
