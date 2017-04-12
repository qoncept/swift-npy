
import Foundation
import SwiftZip

public func load(data: Data) -> NpzData {
    let dict = unzip(data: data)
    return NpzData(dict: dict)
}
