import XCTest
import OSLog
import Foundation
@testable import MartketPlace

let logger: Logger = Logger(subsystem: "MartketPlace", category: "Tests")

@available(macOS 13, *)
final class MartketPlaceTests: XCTestCase {

    func testMartketPlace() throws {
        logger.log("running testMartketPlace")
        XCTAssertEqual(1 + 2, 3, "basic test")
    }

    func testDecodeType() throws {
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("MartketPlace", testData.testModuleName)
    }

}

struct TestData : Codable, Hashable {
    var testModuleName: String
}
