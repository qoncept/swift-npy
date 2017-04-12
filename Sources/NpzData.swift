
import Foundation

public struct NpzData {
    let dict: [String: Data]
    
    public var keys: [String] {
        return dict.keys.map { $0.replacingOccurrences(of: ".npy", with: "") }
    }
    
    public func get<T: DataType>(_ key: String) throws -> NpyData<T> {
        let k: String
        if key.hasSuffix(".npy") {
            k = key
        } else {
            k = key + ".npy"
        }
        if let data = dict[k] {
            return try load(data: data)
        } else {
            throw NpzError.noSuchEntry
        }
    }
}

public enum NpzError: Error {
    case noSuchEntry
}
