
import Foundation
import SwiftZip

extension Npz {
    init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
    
    init(data: Data) throws {
        let dataDict = unzip(data: data)
        
        var dict = [String: Npy]()
        for k in dataDict.keys {
            dict[k] = try Npy(data: dataDict[k]!)
        }
        
        self.init(dict: dict)
    }
}
