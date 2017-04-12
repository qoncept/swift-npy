
import Foundation
import SwiftZip

public func load(contentsOf url: URL) throws -> Npz {
    let data = try Data(contentsOf: url)
    return try load(data: data)
}

public func load(data: Data) throws -> Npz {
    let dataDict = unzip(data: data)
    
    var dict = [String: Npy]()
    for k in dataDict.keys {
        dict[k] = try load(data: dataDict[k]!)
    }
    
    return Npz(dict: dict)
}
