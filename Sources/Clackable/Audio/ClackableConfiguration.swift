import AVFoundation
import Foundation

/// Describes how clack sounds should be played, including audio session behavior and variants.
public struct ClackableConfiguration: Hashable {
    /// Defines how the underlying `AVAudioSession` should be configured before playback.
    public enum SessionBehavior: Hashable {
        case respectSilentSwitch
        case playback
        case custom(category: AVAudioSession.Category, mode: AVAudioSession.Mode = .default, options: AVAudioSession.CategoryOptions = [])

        public static func == (lhs: SessionBehavior, rhs: SessionBehavior) -> Bool {
            switch (lhs, rhs) {
            case (.respectSilentSwitch, .respectSilentSwitch):
                return true
            case (.playback, .playback):
                return true
            case let (.custom(lc, lm, lo), .custom(rc, rm, ro)):
                // Compare by their raw/string identifiers and option raw values
                return lc.rawValue == rc.rawValue && lm.rawValue == rm.rawValue && lo.rawValue == ro.rawValue
            default:
                return false
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
                case .respectSilentSwitch:
                    hasher.combine(0)
                case .playback:
                    hasher.combine(1)
                case let .custom(category, mode, options):
                    hasher.combine(2)
                    hasher.combine(category.rawValue)
                    hasher.combine(mode.rawValue)
                    hasher.combine(options.rawValue)
            }
        }
    }

    public var variants: [SoundVariant]
    public var defaultVolume: Float
    public var sessionBehavior: SessionBehavior

    public init(variants: [SoundVariant], defaultVolume: Float = 1.0, sessionBehavior: SessionBehavior = .respectSilentSwitch) {
        precondition(!variants.isEmpty, "At least one sound variant is required.")
        self.variants = variants
        self.defaultVolume = defaultVolume
        self.sessionBehavior = sessionBehavior
    }
}

public extension ClackableConfiguration {
    static func load(resource: String, withExtension fileExtension: String? = nil, bundle: Bundle = .main, poolCapacity: Int = 2, defaultVolume: Float = 1.0, sessionBehavior: SessionBehavior = .respectSilentSwitch) -> ClackableConfiguration? {
        guard let clip = SoundClip(resource: resource, withExtension: fileExtension, bundle: bundle) else {
            return nil
        }
        return ClackableConfiguration(
            variants: [SoundVariant(clip: clip, poolCapacity: poolCapacity)],
            defaultVolume: defaultVolume,
            sessionBehavior: sessionBehavior
        )
    }
}
