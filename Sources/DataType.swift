
public protocol DataType {
    
}

extension Bool: DataType {}

extension UInt: DataType {}
extension UInt8: DataType {}
extension UInt16: DataType {}
extension UInt32: DataType {}
extension UInt64: DataType {}

extension Int: DataType {}
extension Int8: DataType {}
extension Int16: DataType {}
extension Int32: DataType {}
extension Int64: DataType {}

extension Float: DataType {}
extension Double: DataType {}

public enum NumpyDataType: String {
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
