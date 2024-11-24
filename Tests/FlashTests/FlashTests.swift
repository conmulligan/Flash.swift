import Testing
@testable import Flash

@MainActor
struct FlashTests {
    @Test func testInitCustomConfiguration() {
        let configuration = FlashView.Configuration(alignment: .bottom)
        let flash = FlashView(text: "Test", configuration: configuration)
        #expect(flash.configuration.alignment == configuration.alignment)
    }

    @Test func testInitCustomAnimatorConfiguration() {
        let configuration = DefaultAnimator.Configuration(duration: 10)
        let animator = DefaultAnimator(configuration: configuration)
        #expect(animator.configuration.duration == configuration.duration)
    }

    @Test func testSharedConfiguration() {
        FlashView.Configuration.shared.alignment = .bottom
        let flash = FlashView(text: "Test")
        #expect(flash.configuration.alignment == .bottom)
    }
}
