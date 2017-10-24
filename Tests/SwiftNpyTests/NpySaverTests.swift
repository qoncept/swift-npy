
import XCTest
@testable import SwiftNpy

class NpySaverTests: XCTestCase {
    
    func testFormatB1() {
        let elements = [true, false]
        let npy = Npy(shape: [2], elements: elements, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [Bool] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatU1() {
        let elements = [UInt8.max, UInt8.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [UInt8] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatU2() {
        let elements = [UInt16.max, UInt16.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, endian: .host, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [UInt16] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatU4() {
        let elements = [UInt32.max, UInt32.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, endian: .little, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [UInt32] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatU8() {
        let elements = [UInt64.max, UInt64.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, endian: .big, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [UInt64] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatI1() {
        let elements = [Int8.max, Int8.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [Int8] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatI2() {
        let elements = [Int16.max, Int16.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, endian: .big, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [Int16] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatI4() {
        let elements = [Int32.max, Int32.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, endian: .host, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [Int32] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatI8() {
        let elements = [Int64.max, Int64.min, 0, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, endian: .little, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [Int64] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatF4() {
        let elements: [Float] = [-3, -2, -1, 0, 1, 2]
        let npy = Npy(shape: [3, 2], elements: elements, endian: .host, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [Float] = npy2.elements()
        XCTAssertEqual(e, elements)
    }
    
    func testFormatF8() {
        let elements: [Double] = [-3, -2, -1, 0, 1, 2]
        let shape = [3, 2] + [Int](repeating: 1, count: 65535)
        let npy = Npy(shape: shape, elements: elements, endian: .little, isFortranOrder: false)
        let data = format(npy: npy)
        let npy2: Npy = try! Npy(data: data)
        
        XCTAssertEqual(npy.shape, npy2.shape)
        
        let e: [Double] = npy2.elements()
        XCTAssertEqual(e, elements)
    }

}
