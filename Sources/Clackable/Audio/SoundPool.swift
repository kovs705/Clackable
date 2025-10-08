import AVFoundation
import Foundation

final class SoundPool: NSObject, AVAudioPlayerDelegate {
    private let clip: SoundClip
    private let poolCapacity: Int
    private let defaultVolume: Float
    private var players: [AVAudioPlayer] = []
    private let lock = NSLock()

    init(clip: SoundClip, poolCapacity: Int, defaultVolume: Float) {
        self.clip = clip
        self.poolCapacity = poolCapacity
        self.defaultVolume = defaultVolume
        super.init()
    }

    func warmUp() {
        lock.lock()
        defer { lock.unlock() }
        guard players.isEmpty else { return }
        _ = makePlayer()
    }

    func playOverrideVolume(_ overrideVolume: Float?) {
        guard let player = nextAvailablePlayer() else { return }

        let volume = overrideVolume ?? defaultVolume
        if player.volume != volume {
            player.volume = volume
        }

        player.currentTime = 0
        player.play()
    }

    private func nextAvailablePlayer() -> AVAudioPlayer? {
        lock.lock()
        defer { lock.unlock() }

        if let idle = players.first(where: { !$0.isPlaying }) {
            return idle
        }

        if players.count < poolCapacity, let fresh = makePlayer() {
            return fresh
        }

        guard let player = players.first else {
            return makePlayer()
        }
        player.stop()
        player.currentTime = 0
        return player
    }

    private func makePlayer() -> AVAudioPlayer? {
        do {
            let player = try AVAudioPlayer(contentsOf: clip.url)
            player.delegate = self
            player.volume = defaultVolume
            player.prepareToPlay()
            players.append(player)
            return player
        } catch {
            assertionFailure("Failed to create AVAudioPlayer for \(clip.identifier): \(error)")
            return nil
        }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = 0
    }
}
