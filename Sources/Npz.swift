
import Foundation

public struct Npz {
    private let dict: [String: Npy]
    
    init(dict: [String: Npy]) {
        self.dict = dict
    }
    
    public var keys: [String] {
        return dict.keys.map { $0.replacingOccurrences(of: ".npy", with: "") }
    }
    
    public func get(_ key: String) -> Npy? {
        let k: String
        if key.hasSuffix(".npy") {
            k = key
        } else {
            k = key + ".npy"
        }
        
        return dict[k]
    }
}

public enum NpzError: Error {
    case noSuchEntry
}
