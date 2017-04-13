
import Foundation

public struct Npz {
    private let dict: [String: Npy]
    
    init(dict: [String: Npy]) {
        self.dict = dict
    }
    
    public var keys: [String] {
        return dict.keys.map {
            precondition($0.hasSuffix(".npy"))
            return NSString(string: $0).deletingPathExtension
        }
    }
    
    public subscript(key: String) -> Npy? {
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
