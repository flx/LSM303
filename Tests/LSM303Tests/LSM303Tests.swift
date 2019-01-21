import XCTest
@testable import LSM303

final class LSM303Tests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LSM303().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
