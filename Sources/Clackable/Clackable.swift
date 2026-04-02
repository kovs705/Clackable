import Foundation

/// Namespace for playing short feedback sounds using preloaded player pools.
public enum Clackable {
    /// Prepares the audio session and player pools ahead of the first interaction.
    @MainActor
    public static func preload(_ configuration: ClackableConfiguration) {
        ClackableEngine.shared.prepare(configuration: configuration)
    }

    /// Plays a sound selected from the supplied configuration.
    @MainActor
    public static func play(_ configuration: ClackableConfiguration) {
        ClackableEngine.shared.play(configuration: configuration)
    }

    /// Convenience helper that preloads players for the provided variants.
    @MainActor
    public static func preload(_ variants: [SoundVariant], defaultVolume: Float = 1.0, sessionBehavior: ClackableConfiguration.SessionBehavior = .respectSilentSwitch) {
        let configuration = ClackableConfiguration(variants: variants, defaultVolume: defaultVolume, sessionBehavior: sessionBehavior)
        preload(configuration)
    }

    /// Convenience helper that plays a sound from the provided variants.
    @MainActor
    public static func play(_ variants: [SoundVariant], defaultVolume: Float = 1.0, sessionBehavior: ClackableConfiguration.SessionBehavior = .respectSilentSwitch) {
        let configuration = ClackableConfiguration(variants: variants, defaultVolume: defaultVolume, sessionBehavior: sessionBehavior)
        play(configuration)
    }
}
