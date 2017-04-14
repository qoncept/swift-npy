import Foundation

public struct Npy {
    
    let header: NpyHeader
    let elementsData: Data
    
    public var shape: [Int] {
        return header.shape
    }
    
    var elementsCount: Int {
        return shape.reduce(1, *)
    }
    
    public var dataType: DataType {
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
}

extension Npy {
    public init(shape: [Int], elements: [Bool], isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .bool, isLittleEndian: true, isFortranOrder: isFortranOrder)
        
        self.elementsData = Data(elements.map { $0 ? 0x01 : 0x00 })
    }
    
    public init(shape: [Int], elements: [UInt8], isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .uint8, isLittleEndian: true, isFortranOrder: isFortranOrder)
        
        self.elementsData = Data(elements)
    }
    
    public init(shape: [Int], elements: [UInt16], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .uint16, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)
        
        self.elementsData = toData(elements: elements, isLittleEndian: header.isLittleEndian)
        
    }
    
    public init(shape: [Int], elements: [UInt32], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .uint32, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)
        
        self.elementsData = toData(elements: elements, isLittleEndian: header.isLittleEndian)
    }
    
    public init(shape: [Int], elements: [UInt64], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .uint64, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)
        
        self.elementsData = toData(elements: elements, isLittleEndian: header.isLittleEndian)
    }
    
    public init(shape: [Int], elements: [Int8], isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .int8, isLittleEndian: true, isFortranOrder: isFortranOrder)
        
        let uints = elements.map { UInt8(bitPattern: $0) }
        self.elementsData = Data(uints)
    }
    
    public init(shape: [Int], elements: [Int16], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .int16, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)

        let uints = elements.map { UInt16(bitPattern: $0) }
        self.elementsData = toData(elements: uints,
                                   isLittleEndian: header.isLittleEndian)
    }
    
    public init(shape: [Int], elements: [Int32], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .int32, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)
        
        let uints = elements.map { UInt32(bitPattern: $0) }
        self.elementsData = toData(elements: uints,
                                   isLittleEndian: header.isLittleEndian)
    }
    
    public init(shape: [Int], elements: [Int64], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .int64, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)
        
        let uints = elements.map { UInt64(bitPattern: $0) }
        self.elementsData = toData(elements: uints,
                                   isLittleEndian: header.isLittleEndian)
    }
    
    public init(shape: [Int], elements: [Float], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .float32, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)
        
        let uints = elements.map { $0.bitPattern }
        self.elementsData = toData(elements: uints,
                                   isLittleEndian: header.isLittleEndian)
    }
    
    public init(shape: [Int], elements: [Double], isLittleEndian: Bool, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        self.header = NpyHeader(shape: shape, dataType: .float64, isLittleEndian: isLittleEndian, isFortranOrder: isFortranOrder)
        
        let uints = elements.map { $0.bitPattern }
        self.elementsData = toData(elements: uints,
                                   isLittleEndian: header.isLittleEndian)
    }
}

extension Npy {
    public func elements() -> [Bool] {
        precondition(dataType == .bool)
        let uints = loadUInt8s(data: elementsData, count: elementsCount)
        return uints.map { $0 != 0 }
    }
    
    public func elements() -> [UInt] {
        switch dataType {
        case .uint8:
            let uints = loadUInt8s(data: elementsData, count: elementsCount)
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
    
    public func elements() -> [UInt8] {
        precondition(dataType == .uint8)
        let uints = loadUInt8s(data: elementsData, count: elementsCount)
        return uints
    }
    
    public func elements() -> [UInt16] {
        precondition(dataType == .uint16)
        let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints
    }
    
    public func elements() -> [UInt32] {
        precondition(dataType == .uint32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints
    }
    
    public func elements() -> [UInt64] {
        precondition(dataType == .uint64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints
    }
    
    public func elements() -> [Int] {
        switch dataType {
        case .int8:
            let uints = loadUInt8s(data: elementsData, count: elementsCount)
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
    
    public func elements() -> [Int8] {
        precondition(dataType == .int8)
        let uints = loadUInt8s(data: elementsData, count: elementsCount)
        return uints.map { Int8(bitPattern: $0) }
    }
    
    public func elements() -> [Int16] {
        precondition(dataType == .int16)
        let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Int16(bitPattern: $0) }
    }
    
    public func elements() -> [Int32] {
        precondition(dataType == .int32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Int32(bitPattern: $0) }
    }
    
    public func elements() -> [Int64] {
        precondition(dataType == .int64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Int64(bitPattern: $0) }
    }
    
    public func elements() -> [Float] {
        precondition(dataType == .float32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Float(bitPattern: $0) }
    }
    
    public func elements() -> [Double] {
        precondition(dataType == .float64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, isLittleEndian: isLittleEndian)
        return uints.map { Double(bitPattern: $0) }
    }
}
