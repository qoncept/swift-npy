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
    
    public var endian: Endian {
        return header.endian
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
        let header = NpyHeader(shape: shape, dataType: .bool, endian: .na, isFortranOrder: isFortranOrder)
        let data = Data(elements.map { $0 ? 0x01 : 0x00 })
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [UInt8], isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .uint8, endian: .na, isFortranOrder: isFortranOrder)
        let data = Data(elements)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [UInt16], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .uint16, endian: endian, isFortranOrder: isFortranOrder)
        let data = toData(elements: elements, endian: header.endian)
        self.init(header: header, elementsData: data)
        
    }
    
    public init(shape: [Int], elements: [UInt32], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .uint32, endian: endian, isFortranOrder: isFortranOrder)
        let data = toData(elements: elements, endian: header.endian)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [UInt64], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .uint64, endian: endian, isFortranOrder: isFortranOrder)
        let data = toData(elements: elements, endian: header.endian)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [Int8], isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .int8, endian: .na, isFortranOrder: isFortranOrder)
        let uints = elements.map { UInt8(bitPattern: $0) }
        let data = Data(uints)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [Int16], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .int16, endian: endian, isFortranOrder: isFortranOrder)
        let uints = elements.map { UInt16(bitPattern: $0) }
        let data = toData(elements: uints,
                                   endian: header.endian)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [Int32], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .int32, endian: endian, isFortranOrder: isFortranOrder)
        let uints = elements.map { UInt32(bitPattern: $0) }
        let data = toData(elements: uints,
                                   endian: header.endian)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [Int64], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .int64, endian: endian, isFortranOrder: isFortranOrder)
        let uints = elements.map { UInt64(bitPattern: $0) }
        let data = toData(elements: uints,
                                   endian: header.endian)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [Float], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .float32, endian: endian, isFortranOrder: isFortranOrder)
        let uints = elements.map { $0.bitPattern }
        let data = toData(elements: uints,
                                   endian: header.endian)
        self.init(header: header, elementsData: data)
    }
    
    public init(shape: [Int], elements: [Double], endian: Endian, isFortranOrder: Bool) {
        precondition(shape.reduce(1, *) == elements.count)
        let header = NpyHeader(shape: shape, dataType: .float64, endian: endian, isFortranOrder: isFortranOrder)
        let uints = elements.map { $0.bitPattern }
        let data = toData(elements: uints,
                                   endian: header.endian)
        self.init(header: header, elementsData: data)
    }
}

extension Npy {
    public func elements(_ type: Bool.Type = Bool.self) -> [Bool] {
        precondition(dataType == .bool)
        let uints = loadUInt8s(data: elementsData, count: elementsCount)
        return uints.map { $0 != 0 }
    }
    
    public func elements(_ type: UInt.Type = UInt.self) -> [UInt] {
        switch dataType {
        case .uint8:
            let uints = loadUInt8s(data: elementsData, count: elementsCount)
            return uints.map { UInt($0) }
        case .uint16:
            let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
            return uints.map { UInt($0) }
        case .uint32:
            let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
            return uints.map { UInt($0) }
        case .uint64:
            let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
            return uints.map { UInt($0) }
        default:
            preconditionFailure()
        }
    }
    
    public func elements(_ type: UInt8.Type = UInt8.self) -> [UInt8] {
        precondition(dataType == .uint8)
        let uints = loadUInt8s(data: elementsData, count: elementsCount)
        return uints
    }
    
    public func elements(_ type: UInt16.Type = UInt16.self) -> [UInt16] {
        precondition(dataType == .uint16)
        let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints
    }
    
    public func elements(_ type: UInt32.Type = UInt32.self) -> [UInt32] {
        precondition(dataType == .uint32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints
    }
    
    public func elements(_ type: UInt64.Type = UInt64.self) -> [UInt64] {
        precondition(dataType == .uint64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints
    }
    
    public func elements(_ type: Int.Type = Int.self) -> [Int] {
        switch dataType {
        case .int8:
            let uints = loadUInt8s(data: elementsData, count: elementsCount)
            return uints.map { Int(Int8(bitPattern: $0)) }
        case .int16:
            let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
            return uints.map { Int(Int16(bitPattern: $0)) }
        case .int32:
            let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
            return uints.map { Int(Int32(bitPattern: $0)) }
        case .int64:
            let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
            return uints.map { Int(Int64(bitPattern: $0)) }
        default:
            preconditionFailure()
        }
    }
    
    public func elements(_ type: Int8.Type = Int8.self) -> [Int8] {
        precondition(dataType == .int8)
        let uints = loadUInt8s(data: elementsData, count: elementsCount)
        return uints.map { Int8(bitPattern: $0) }
    }
    
    public func elements(_ type: Int16.Type = Int16.self) -> [Int16] {
        precondition(dataType == .int16)
        let uints: [UInt16] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints.map { Int16(bitPattern: $0) }
    }
    
    public func elements(_ type: Int32.Type = Int32.self) -> [Int32] {
        precondition(dataType == .int32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints.map { Int32(bitPattern: $0) }
    }
    
    public func elements(_ type: Int64.Type = Int64.self) -> [Int64] {
        precondition(dataType == .int64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints.map { Int64(bitPattern: $0) }
    }
    
    public func elements(_ type: Float.Type = Float.self) -> [Float] {
        precondition(dataType == .float32)
        let uints: [UInt32] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints.map { Float(bitPattern: $0) }
    }
    
    public func elements(_ type: Double.Type = Double.self) -> [Double] {
        precondition(dataType == .float64)
        let uints: [UInt64] = loadUInts(data: elementsData, count: elementsCount, endian: endian)
        return uints.map { Double(bitPattern: $0) }
    }
}
