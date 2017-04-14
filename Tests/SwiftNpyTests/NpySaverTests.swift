
import XCTest
@testable import SwiftNpy

class NpySaverTests: XCTestCase {

    func testFormatB1() {
        let npy: Npy = try! load(data: b1)
        let data = format(npy: npy)
        let npy2: Npy = try! load(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e1: [Bool] = npy.elements()
        let e2: [Bool] = npy2.elements()
        XCTAssertEqual(e1, e2)
    }
    
    func testFormatF8() {
        let npy: Npy = try! load(data: f8)
        let data = format(npy: npy)
        let npy2: Npy = try! load(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e1: [Double] = npy.elements()
        let e2: [Double] = npy2.elements()
        XCTAssertEqual(e1, e2)
    }

}
