import XCTest
@testable import MyTwitterDrop

final class MyTwitterDropTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MyTwitterDrop().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
