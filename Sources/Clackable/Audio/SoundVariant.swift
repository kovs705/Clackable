import Foundation

/// Describes a playable variant for a clack sound.
public struct SoundVariant: Hashable, Sendable {
    public let clip: SoundClip
    public let weight: Double
    public let volume: Float?
    public let poolCapacity: Int

    public init(clip: SoundClip, weight: Double = 1.0, volume: Float? = nil, poolCapacity: Int = 2) {
        precondition(weight > 0, "Weight must be greater than zero.")
        precondition(poolCapacity > 0, "Pool capacity must be greater than zero.")
        self.clip = clip
        self.weight = weight
        self.volume = volume
        self.poolCapacity = poolCapacity
    }
}

