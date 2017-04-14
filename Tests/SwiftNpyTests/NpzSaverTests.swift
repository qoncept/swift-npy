
import XCTest
@testable import SwiftNpy

class NpzSaverTests: XCTestCase {

    func testFormat() {
        let npz1: Npz = try! load(data: npz)
        
        let a1: Npy = npz1["a"]!
        let a1Elements: [Int] = a1.elements()
        let b1: Npy = npz1["b"]!
        let b1Elements: [Int] = b1.elements()
        
        let data = format(npz: npz1)
        
        let npz2: Npz = try! load(data: data)
        
        XCTAssertEqual(Set(npz2.keys), Set(npz1.keys))
        
        let a2: Npy = npz1["a"]!
        let a2Elements: [Int] = a2.elements()
        let b2: Npy = npz1["b"]!
        let b2Elements: [Int] = b2.elements()
        XCTAssertEqual(a2Elements, a1Elements)
        XCTAssertEqual(b2Elements, b1Elements)
    }

}
