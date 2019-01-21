import XCTest

import LSM303Tests

var tests = [XCTestCaseEntry]()
tests += LSM303Tests.allTests()
XCTMain(tests)