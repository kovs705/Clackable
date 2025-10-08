import AVFoundation
import Foundation

@MainActor
final class ClackableEngine {
    static let shared = ClackableEngine()

    private let session = AVAudioSession.sharedInstance()
    private var activeBehavior: ClackableConfiguration.SessionBehavior?
    private var pools: [SoundClip: SoundPool] = [:]

    private init() {}

    func play(configuration: ClackableConfiguration) {
        configureSessionIfNeeded(configuration.sessionBehavior)
        let variant = pickVariant(from: configuration.variants)
        let pool = pool(for: variant, defaultVolume: configuration.defaultVolume)
        pool.playOverrideVolume(variant.volume)
    }

    private func configureSessionIfNeeded(_ behavior: ClackableConfiguration.SessionBehavior) {
        guard behavior != activeBehavior else { return }

        do {
            switch behavior {
            case .respectSilentSwitch:
                try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            case .playback:
                try session.setCategory(.playback, mode: .default, options: [])
            case let .custom(category, mode, options):
                try session.setCategory(category, mode: mode, options: options)
            }
            try session.setActive(true, options: [])
            activeBehavior = behavior
        } catch {
            assertionFailure("Failed to configure audio session: \(error)")
        }
    }

    private func pool(for variant: SoundVariant, defaultVolume: Float) -> SoundPool {
        if let pooled = pools[variant.clip] {
            return pooled
        }

        let created = SoundPool(clip: variant.clip, poolCapacity: variant.poolCapacity, defaultVolume: defaultVolume)
        created.warmUp()
        pools[variant.clip] = created
        return created
    }

    private func pickVariant(from variants: [SoundVariant]) -> SoundVariant {
        if variants.count == 1 {
            return variants[0]
        }

        let totalWeight = variants.reduce(0.0) { $0 + $1.weight }
        guard totalWeight > 0 else { return variants[0] }

        let target = Double.random(in: 0 ..< totalWeight)
        var accumulator = 0.0

        for variant in variants {
            accumulator += variant.weight
            if target < accumulator {
                return variant
            }
        }
        return variants.last ?? variants[0]
    }
}

