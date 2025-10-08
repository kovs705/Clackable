import Foundation

#if canImport(UIKit)
import ObjectiveC
import UIKit

@MainActor private final class ClackableControlTarget: NSObject {
    var configuration: ClackableConfiguration

    init(configuration: ClackableConfiguration) {
        self.configuration = configuration
        super.init()
    }

    @MainActor @objc func trigger() {
        Clackable.play(configuration)
    }
}

@MainActor private final class ClackableGestureTarget: NSObject {
    let configuration: ClackableConfiguration

    init(configuration: ClackableConfiguration) {
        self.configuration = configuration
    }

    @MainActor @objc func trigger() {
        Clackable.play(configuration)
    }
}

@MainActor private final class ClackableTargetStorage: NSObject {
    var controlTargets: [UInt: ClackableControlTarget] = [:]
    var gestureTargets: [ObjectIdentifier: ClackableGestureTarget] = [:]
}

@MainActor private var clackableStorageKey: UInt8 = 0

@MainActor private extension NSObject {
    var clackableTargetStorage: ClackableTargetStorage {
        if let storage = objc_getAssociatedObject(self, &clackableStorageKey) as? ClackableTargetStorage {
            return storage
        }
        let storage = ClackableTargetStorage()
        objc_setAssociatedObject(self, &clackableStorageKey, storage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return storage
    }
}

@MainActor public extension UIControl {
    /// Adds a handler that plays clack sounds whenever the control emits the specified UIControl events.
    func enableClacks(_ configuration: ClackableConfiguration, for events: UIControl.Event = .touchUpInside) {
        let storage = clackableTargetStorage
        let target = storage.controlTargets[events.rawValue] ?? ClackableControlTarget(configuration: configuration)
        target.configuration = configuration
        storage.controlTargets[events.rawValue] = target
        addTarget(target, action: #selector(ClackableControlTarget.trigger), for: events)
    }

    /// Removes the clack handler previously added for the specified control events.
    func disableClacks(for events: UIControl.Event = .touchUpInside) {
        let storage = clackableTargetStorage
        guard let target = storage.controlTargets.removeValue(forKey: events.rawValue) else { return }
        removeTarget(target, action: #selector(ClackableControlTarget.trigger), for: events)
    }
}

@MainActor public extension UIView {
    /// Adds a tap gesture recognizer that plays clack sounds when it fires.
    @discardableResult
    func addClackTapGesture(tapsRequired: Int = 1, touchesRequired: Int = 1, configuration: ClackableConfiguration) -> UITapGestureRecognizer {
        let target = ClackableGestureTarget(configuration: configuration)
        let recognizer = UITapGestureRecognizer(target: target, action: #selector(ClackableGestureTarget.trigger))
        recognizer.numberOfTapsRequired = tapsRequired
        recognizer.numberOfTouchesRequired = touchesRequired
        recognizer.cancelsTouchesInView = false
        addGestureRecognizer(recognizer)

        let storage = clackableTargetStorage
        storage.gestureTargets[ObjectIdentifier(recognizer)] = target
        return recognizer
    }

    /// Removes a previously added clack tap gesture recognizer.
    func removeClackTapGesture(_ recognizer: UITapGestureRecognizer) {
        let key = ObjectIdentifier(recognizer)
        guard let target = clackableTargetStorage.gestureTargets.removeValue(forKey: key) else { return }
        recognizer.removeTarget(target, action: #selector(ClackableGestureTarget.trigger))
        removeGestureRecognizer(recognizer)
    }
}

#endif
