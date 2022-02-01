
import Foundation
import SwiftZip

extension Npz {
    public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
    
    public init(data: Data) throws {
        let source = try ZipSource(data: data)
        let archive = try ZipArchive(source: source)
        
        var dict = [String: Npy]()
        for entry in archive.entries() {
            let entryName = try entry.getName()
            let entryData = try entry.data()
            dict[entryName] = try Npy(data: entryData)
        }
        
        self.init(dict: dict)
    }
}
