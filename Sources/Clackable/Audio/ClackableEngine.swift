import AVFoundation
import Foundation

@MainActor
final class ClackableEngine {
    static let shared = ClackableEngine()

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    private let session = AVAudioSession.sharedInstance()
    #endif
    private var activeBehavior: ClackableConfiguration.SessionBehavior?
    private var pools: [SoundClip: SoundPool] = [:]

    private init() {}

    func prepare(configuration: ClackableConfiguration) {
        configureSessionIfNeeded(configuration.sessionBehavior)

        for variant in configuration.variants {
            let pool = pool(for: variant)
            pool.warmUp()
        }
    }

    func play(configuration: ClackableConfiguration) {
        configureSessionIfNeeded(configuration.sessionBehavior)
        let variant = pickVariant(from: configuration.variants)
        let pool = pool(for: variant)
        pool.play(volume: variant.volume ?? configuration.defaultVolume)
    }

    private func configureSessionIfNeeded(_ behavior: ClackableConfiguration.SessionBehavior) {
        guard behavior != activeBehavior else { return }

        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        do {
            switch behavior {
            case .respectSilentSwitch:
                try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            case .playback:
                try session.setCategory(.playback, mode: .default, options: [])
            #if canImport(AVFoundation) && (os(iOS) || os(tvOS) || targetEnvironment(macCatalyst))
            case let .custom(category, mode, options):
                try session.setCategory(category, mode: mode, options: options)
            #endif
            }
            try session.setActive(true, options: [])
            activeBehavior = behavior
        } catch {
            assertionFailure("Failed to configure audio session: \(error)")
        }
        #else
        activeBehavior = behavior
        #endif
    }

    private func pool(for variant: SoundVariant) -> SoundPool {
        if let pooled = pools[variant.clip] {
            pooled.reserveCapacity(variant.poolCapacity)
            return pooled
        }

        let created = SoundPool(clip: variant.clip, poolCapacity: variant.poolCapacity)
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
