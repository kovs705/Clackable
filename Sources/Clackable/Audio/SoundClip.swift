import Foundation

/// Represents an audio resource that can be loaded from a bundle or a URL.
public struct SoundClip: Hashable, Sendable {
    public let url: URL
    public let identifier: String

    public init(url: URL, identifier: String? = nil) {
        self.url = url
        self.identifier = identifier ?? url.lastPathComponent
    }

    public init?(resource: String, withExtension fileExtension: String? = nil, bundle: Bundle = .main) {
        guard let resolvedURL = bundle.url(forResource: resource, withExtension: fileExtension) else {
            return nil
        }
        self.init(url: resolvedURL, identifier: [resource, fileExtension].compactMap { $0 }.joined(separator: "."))
    }
}

