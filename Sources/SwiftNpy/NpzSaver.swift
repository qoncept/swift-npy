
import Foundation
import SwiftZip

extension Npz {
    public func save(to url: URL) throws {
        let archive = try ZipMutableArchive(url: url, flags: [.create, .truncate])
        
        for (name, npy) in dict {
            let source = try ZipSource(data: npy.format())
            try archive.addFile(name: name, source: source)
        }
        
        try archive.close()
    }
}
