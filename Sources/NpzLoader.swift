
import Foundation
import SwiftZip

public func load(data: Data) -> Npz {
    let dict = unzip(data: data)
    return Npz(dict: dict)
}
