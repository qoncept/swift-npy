import XCTest
@testable import SwiftNpyTests

XCTMain([
    testCase(NpyLoaderTests.allTests),
    testCase(NpySaverTests.allTests),
    testCase(NpzLoaderTests.allTests),
    testCase(NpzSaverTests.allTests),
])
