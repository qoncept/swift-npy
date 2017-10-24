
import Foundation
import SwiftZip

func save(npz: Npz, to url: URL) throws {
    let data = format(npz: npz)
    try data.write(to: url)
}

func format(npz: Npz) -> Data {
    var entries = [String: Data]()
    for (k, v) in npz.dict {
        entries[k] = format(npy: v)
    }
    return createZip(entries: entries)
}
