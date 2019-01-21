import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LSM303Tests.allTests),
    ]
}
#endif