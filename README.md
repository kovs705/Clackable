<div align="center">
<img width="300" height="300" src="/Assets/Clackable.png" alt="Clackable icon">

# Clackable

*`Clackable` is a lightweight Swift package for adding short tactile "click" or "clack" sounds to UI interactions.*

</div>

---

It is designed for app interfaces where you want quick, low-friction audio feedback for taps, long presses, buttons, toggles, or custom gestures.

## Features

- Simple API for preloading and playing short UI sounds
- SwiftUI support with a `View.clackable(...)` modifier
- UIKit helpers for `UIControl` and `UIView`
- Weighted random sound variants for more natural feedback
- Configurable audio-session behavior
- Built-in player pooling so repeated taps stay responsive
- Includes a few bundled sounds you can use immediately

## Supported Platforms

- iOS 14+
- tvOS 14+
- Mac Catalyst 14+

## Installation

### Xcode

Add the package using:

```text
https://github.com/kovs705/Clackable.git
```

This repository does not currently expose a tagged release, so use the `main` branch when adding it in Xcode.

### `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/kovs705/Clackable.git", branch: "main")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "Clackable", package: "Clackable")
        ]
    )
]
```

## Quick Start

The basic flow is:

1. Create a `SoundClip`
2. Wrap it in a `ClackableConfiguration`
3. Optionally preload it
4. Play it when the interaction happens

```swift
import Clackable

@MainActor
final class SoundCoordinator {
    static let shared = SoundCoordinator()

    let tapConfiguration: ClackableConfiguration

    init() {
        guard let clip = SoundClip(
            resource: "tap",
            withExtension: "wav",
            bundle: .main
        ) else {
            fatalError("Missing sound resource: tap.wav")
        }

        tapConfiguration = ClackableConfiguration(
            variants: [
                SoundVariant(clip: clip, poolCapacity: 3)
            ],
            defaultVolume: 0.9
        )
    }

    func preload() {
        Clackable.preload(tapConfiguration)
    }

    func playTap() {
        Clackable.play(tapConfiguration)
    }
}
```

Call `preload()` somewhere early, such as app launch or the first screen's `.task`, if you want the first interaction to feel as immediate as possible.

## Sound Files

You can load clips from:

- Your app bundle with `bundle: .main`
- A Swift package's processed resources with `bundle: .module`
- Clackable's bundled sounds with `bundle: .clackableDefault`
- Any other bundle you pass explicitly

`SoundClip(resource:withExtension:bundle:)` searches recursively inside the bundle's resources, so your sound files can live in subfolders.

## Using the Bundled Sounds

Clackable ships with a few ready-to-use sounds for testing or quick integration.

```swift
import Clackable

let config = ClackableConfiguration(
    variants: [
        SoundVariant(
            clip: SoundClip(
                resource: "breviceps__wet-click",
                withExtension: "wav",
                bundle: .clackableDefault
            )!,
            volume: 0.9
        )
    ]
)
```

Bundled sound licenses live alongside the audio files in the package resources. Review those files before shipping them in a production app.

## SwiftUI

For SwiftUI, the easiest path is the built-in modifier:

```swift
import Clackable
import SwiftUI

struct ContentView: View {
    private let clack = ClackableConfiguration(
        variants: [
            SoundVariant(
                clip: SoundClip(
                    resource: "breviceps__tic-toc-click",
                    withExtension: "wav",
                    bundle: .clackableDefault
                )!,
                poolCapacity: 2
            )
        ]
    )

    var body: some View {
        VStack(spacing: 16) {
            Button("Primary Action") {
                // Your action here
            }
            .buttonStyle(.borderedProminent)
            .clackable(clack)

            Text("Press and hold me")
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 12))
                .clackable(
                    clack,
                    trigger: .longPress(minimumDuration: 0.35)
                )
        }
        .task {
            Clackable.preload(clack)
        }
    }
}
```

Available SwiftUI triggers:

- `.tap(count: Int = 1)`
- `.longPress(minimumDuration: Double = 0.5, maximumDistance: CGFloat = 10)`

Use `.clackable(...)` when you want the sound attached to the interaction itself, not buried inside your action code.

## UIKit

### `UIControl`

Attach clacks directly to controls:

```swift
import Clackable
import UIKit

final class ViewController: UIViewController {
    @IBOutlet private weak var button: UIButton!

    private lazy var clack = makeClack()

    override func viewDidLoad() {
        super.viewDidLoad()
        Clackable.preload(clack)
        button.enableClacks(clack, for: .touchUpInside)
    }

    private func makeClack() -> ClackableConfiguration {
        let clip = SoundClip(
            resource: "tap",
            withExtension: "wav",
            bundle: .main
        )!

        return ClackableConfiguration(
            variants: [SoundVariant(clip: clip)]
        )
    }
}
```

Remove it later if needed:

```swift
button.disableClacks(for: .touchUpInside)
```

### `UIView`

Attach a tap recognizer that plays a sound:

```swift
let recognizer = cardView.addClackTapGesture(configuration: clack)

// Later, if needed:
cardView.removeClackTapGesture(recognizer)
```

## Using Multiple Variants

Multiple variants help repeated interactions feel less robotic.

```swift
import Clackable

let soft = SoundClip(resource: "soft-click", withExtension: "wav", bundle: .main)!
let sharp = SoundClip(resource: "sharp-click", withExtension: "wav", bundle: .main)!
let muted = SoundClip(resource: "muted-click", withExtension: "wav", bundle: .main)!

let configuration = ClackableConfiguration(
    variants: [
        SoundVariant(clip: soft, weight: 3, volume: 0.85, poolCapacity: 3),
        SoundVariant(clip: sharp, weight: 1, volume: 1.0, poolCapacity: 2),
        SoundVariant(clip: muted, weight: 2, volume: 0.75, poolCapacity: 2)
    ],
    defaultVolume: 0.9
)
```

Notes:

- Higher `weight` means the variant is picked more often
- `volume` on a `SoundVariant` overrides `defaultVolume`
- Increase `poolCapacity` if the same sound may overlap during fast repeated taps

## Audio Session Behavior

`ClackableConfiguration` lets you control how audio playback should behave:

```swift
let configuration = ClackableConfiguration(
    variants: [SoundVariant(clip: clip)],
    sessionBehavior: .respectSilentSwitch
)
```

Options:

- `.respectSilentSwitch`
  Best for subtle UI feedback. On iOS-family platforms this uses an ambient-style session that mixes with other audio.
- `.playback`
  Use this when you want sounds to play even when the silent switch is enabled.
- `.custom(category:mode:options:)`
  Available on iOS, tvOS, and Mac Catalyst when you need full control over the underlying `AVAudioSession`.

## API Overview

### Core Types

- `Clackable`
  Namespace with `preload(...)` and `play(...)`
- `ClackableConfiguration`
  Holds the variants, default volume, and audio-session behavior
- `SoundVariant`
  Defines one candidate clip, plus weight, optional volume override, and pool capacity
- `SoundClip`
  Wraps a URL-backed audio resource
- `ClackTrigger`
  SwiftUI trigger enum for tap and long press interactions

### Main Entry Points

```swift
Clackable.preload(_ configuration: ClackableConfiguration)
Clackable.play(_ configuration: ClackableConfiguration)

Clackable.preload(
    _ variants: [SoundVariant],
    defaultVolume: Float = 1.0,
    sessionBehavior: ClackableConfiguration.SessionBehavior = .respectSilentSwitch
)

Clackable.play(
    _ variants: [SoundVariant],
    defaultVolume: Float = 1.0,
    sessionBehavior: ClackableConfiguration.SessionBehavior = .respectSilentSwitch
)
```

These APIs are `@MainActor`, so call them from UI code or hop to the main actor before playing sounds.

## Tips

- Preload sounds that will be used on the first interaction of a screen
- Keep clips short for the best "tactile" feel
- Reuse `ClackableConfiguration` instances instead of rebuilding them for every tap
- Use a slightly larger `poolCapacity` for controls that users can tap rapidly
- Start with subtle volume values; UI sound effects usually work better when they are felt more than noticed

## License

This repository contains third-party bundled sound assets with their own license files in the resources directory. Review those licenses before redistributing the included sounds.
