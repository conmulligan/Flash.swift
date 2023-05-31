import XCTest
@testable import Flash

final class FlashTests: XCTestCase {
    func testInitCustomConfiguration() {
        let configuration = FlashView.Configuration(alignment: .bottom)
        let flash = FlashView(text: "Test", configuration: configuration)
        XCTAssert(flash.configuration.alignment == configuration.alignment)
    }
    
    func testInitCustomAnimatorConfiguration() throws {
        let configuration = DefaultAnimator.Configuration(duration: 10)
        let animator = DefaultAnimator(configuration: configuration)
        XCTAssert(animator.configuration.duration == configuration.duration)
    }
}
