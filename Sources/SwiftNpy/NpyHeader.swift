
import Foundation

let MAGIC_PREFIX = "\u{93}NUMPY"

struct NpyHeader {
    let shape: [Int]
    let dataType: DataType
    let endian: Endian
    let isFortranOrder: Bool
    let descr: String
    
    init(shape: [Int], dataType: DataType, endian: Endian, isFortranOrder: Bool, descr: String) {
        self.shape = shape
        self.dataType = dataType
        self.endian = endian
        self.isFortranOrder = isFortranOrder
        self.descr = descr
    }
    
    init(shape: [Int], dataType: DataType, endian: Endian, isFortranOrder: Bool) {
        let descr = "'" + endian.rawValue + dataType.rawValue + "'"
        self.init(shape: shape,
                  dataType: dataType,
                  endian: endian,
                  isFortranOrder: isFortranOrder,
                  descr: descr)
    }
}

// https://docs.scipy.org/doc/numpy/reference/generated/numpy.dtype.byteorder.html
public enum Endian: String {
    case host = "="
    case big = ">"
    case little = "<"
    case na = "|"
    
    static var all: [Endian] {
        return [.host, .big, .little, .na]
    }
}

func parseHeader(_ data: Data) throws -> NpyHeader {
    
    guard let str = String(data: data, encoding: .ascii) else {
        throw NpyLoaderError.ParseFailed(message: "Failed to load header")
    }
    
    let descr: String
    let endian: Endian
    let dataType: DataType
    let isFortranOrder: Bool
    do {
        let separate = str.components(separatedBy: CharacterSet(charactersIn: ", ")).filter { !$0.isEmpty }
        
        guard let descrIndex = separate.index(where: { $0.contains("descr") }) else {
            throw NpyLoaderError.ParseFailed(message: "Header does not contain the key 'descr'")
        }
        descr = separate[descrIndex + 1]
        
        guard let e = Endian.all.filter({ descr.contains($0.rawValue) }).first else {
            throw NpyLoaderError.ParseFailed(message: "Unknown endian")
        }
        endian = e
        
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
        
        let substr = str[left.upperBound..<right.lowerBound]
        
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
                     endian: endian,
                     isFortranOrder: isFortranOrder,
                     descr: descr)
}

func encodeHeader(_ header: NpyHeader) -> Data {
    let fortran_order = header.isFortranOrder ? "True" : "False"
    let shape: String
    switch header.shape.count {
    case 0:
        shape = "()"
    case 1:
        shape = "(\(header.shape[0]),)"
    default:
        shape = "(" + header.shape.map(String.init).joined(separator: ", ") + ")"
    }
    
    let str = "{ 'descr': \(header.descr), 'fortran_order': \(fortran_order), 'shape': \(shape), }"
    return str.data(using: .ascii)!
}
