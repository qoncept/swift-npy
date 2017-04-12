
import Foundation

public struct Npz {
    private let dict: [String: Data]
    
    init(dict: [String: Data]) {
        self.dict = dict
    }
    
    public var keys: [String] {
        return dict.keys.map { $0.replacingOccurrences(of: ".npy", with: "") }
    }
    
    public func get(_ key: String) throws -> Npy {
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
