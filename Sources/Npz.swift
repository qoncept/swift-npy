
import Foundation

public struct Npz {
    private let dict: [String: Npy]
    
    public init(dict: [String: Npy]) {
        var npyDict = [String:Npy]()
        for (k, v) in dict {
            if k.hasSuffix(".npy") {
                npyDict[k] = v
            } else {
                npyDict[k+".npy"] = v
            }
        }
        
        self.dict = npyDict
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
