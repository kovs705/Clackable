import Foundation

public extension Bundle {
    static var clackableDefault: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }
}
