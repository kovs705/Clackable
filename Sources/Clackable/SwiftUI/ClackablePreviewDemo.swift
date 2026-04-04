import Foundation

#if DEBUG && canImport(SwiftUI)
import SwiftUI

@available(iOS 17.0, tvOS 17.0, macOS 14.0, macCatalyst 17.0, *)
private struct ClackablePreviewDemo: View {
    @State private var hasAutoPlayed = false

    private let previewConfiguration = Self.makePreviewConfiguration()
    private let wetClickConfiguration = Self.makeSingleSoundConfiguration(
        resource: "breviceps__wet-click",
        fileExtension: "wav",
        volume: 0.9
    )
    private let ticTocConfiguration = Self.makeSingleSoundConfiguration(
        resource: "breviceps__tic-toc-click",
        fileExtension: "wav",
        volume: 0.8
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clackable Preview")
                .font(.headline)

            Text("Open this preview in Live or Interactive mode to hear two automatic clicks without pressing any buttons.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("If your Mac is muted or Xcode is only showing a static snapshot, you won’t hear anything.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Wet Click") {
                    Clackable.play(wetClickConfiguration)
                }
                .buttonStyle(.borderedProminent)

                Button("Tic-Toc Click") {
                    Clackable.play(ticTocConfiguration)
                }
                .buttonStyle(.bordered)

                Button("Random Pair") {
                    Clackable.play(previewConfiguration)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: 360, alignment: .leading)
        .task {
            guard !hasAutoPlayed else { return }
            hasAutoPlayed = true

            Clackable.preload(previewConfiguration)
            Clackable.preload(wetClickConfiguration)
            Clackable.preload(ticTocConfiguration)

            try? await Task.sleep(for: .milliseconds(400))
            Clackable.play(previewConfiguration)

            try? await Task.sleep(for: .milliseconds(500))
            Clackable.play(previewConfiguration)
        }
    }

    private static func makePreviewConfiguration() -> ClackableConfiguration {
        guard
            let wetClick = SoundClip(
                resource: "breviceps__wet-click",
                withExtension: "wav",
                bundle: .clackableDefault
            ),
            let ticTocClick = SoundClip(
                resource: "breviceps__tic-toc-click",
                withExtension: "wav",
                bundle: .clackableDefault
            )
        else {
            fatalError("Missing bundled preview sounds.")
        }

        return ClackableConfiguration(
            variants: [
                SoundVariant(clip: wetClick, weight: 1.0, volume: 0.9, poolCapacity: 2),
                SoundVariant(clip: ticTocClick, weight: 1.0, volume: 0.8, poolCapacity: 2),
            ],
            defaultVolume: 0.9
        )
    }

    private static func makeSingleSoundConfiguration(
        resource: String,
        fileExtension: String,
        volume: Float
    ) -> ClackableConfiguration {
        guard let clip = SoundClip(
            resource: resource,
            withExtension: fileExtension,
            bundle: .clackableDefault
        ) else {
            fatalError("Missing bundled preview sound: \(resource).\(fileExtension)")
        }

        return ClackableConfiguration(
            variants: [
                SoundVariant(clip: clip, volume: volume, poolCapacity: 2)
            ],
            defaultVolume: volume
        )
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, macCatalyst 17.0, *)
#Preview("Auto Play Demo") {
    ClackablePreviewDemo()
}

#endif
