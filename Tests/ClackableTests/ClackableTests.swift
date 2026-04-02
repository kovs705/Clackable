import Testing
@testable import Clackable

@Test func loadsBundledSoundFromProcessedResources() throws {
    let configuration = ClackableConfiguration.load(
        resource: "breviceps__wet-click",
        withExtension: "wav"
    )

    #expect(configuration != nil)
}

@Test @MainActor func preloadAndPlayBundledSound() throws {
    let configuration = try #require(
        ClackableConfiguration.load(
            resource: "breviceps__wet-click",
            withExtension: "wav"
        )
    )

    Clackable.preload(configuration)
    Clackable.play(configuration)
}
