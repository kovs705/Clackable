import Foundation

#if canImport(SwiftUI)
import SwiftUI

/// Defines the user interaction that should trigger a clack sound for SwiftUI views.
public enum ClackTrigger: Sendable, Equatable {
    case tap(count: Int = 1)
    case longPress(minimumDuration: Double = 0.5, maximumDistance: CGFloat = 10)
}

private struct ClackableViewModifier: ViewModifier {
    let configuration: ClackableConfiguration
    let trigger: ClackTrigger

    func body(content: Content) -> some View {
        switch trigger {
        case let .tap(count):
            content.simultaneousGesture(
                TapGesture(count: count)
                    .onEnded {
                        Clackable.play(configuration)
                    }
            )
        case let .longPress(minimumDuration, maximumDistance):
            content.simultaneousGesture(
                LongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance)
                    .onEnded { _ in
                        Clackable.play(configuration)
                    }
            )
        }
    }
}

public extension View {
    func clackable(_ configuration: ClackableConfiguration, trigger: ClackTrigger = .tap()) -> some View {
        modifier(ClackableViewModifier(configuration: configuration, trigger: trigger))
    }
}

#endif
