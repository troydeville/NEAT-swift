import XCTest
@testable import Neat

final class NeatTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Neat(inputs: 2, outputs: 1, population: 200).network.populationCount(), 200)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
