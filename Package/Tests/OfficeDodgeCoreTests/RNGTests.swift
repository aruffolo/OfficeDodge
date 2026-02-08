import OfficeDodgeCore
import XCTest

final class RNGTests: XCTestCase {
    func testSeedProducesStableFirstTenValues() {
        var rng = SeededRNG(seed: 0xDEADBEEFCAFEBABE)
        let expected: [UInt64] = [
            972095092378118610,
            5268643614968304703,
            4787937682015542909,
            15477334834514230341,
            12885830976614912075,
            13210788322518306982,
            690269794703133666,
            8749140072506628481,
            16107729285669613983,
            18320266961420301089,
        ]

        let actual = (0..<expected.count).map { _ in rng.nextUInt64() }
        XCTAssertEqual(actual, expected)
    }
}
