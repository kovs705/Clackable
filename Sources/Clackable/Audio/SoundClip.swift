import Foundation

/// Represents an audio resource that can be loaded from a bundle or a URL.
public struct SoundClip: Hashable, Sendable {
    public let url: URL
    public let identifier: String

    public init(url: URL, identifier: String? = nil) {
        self.url = url
        self.identifier = identifier ?? url.lastPathComponent
    }

    public init?(resource: String, withExtension fileExtension: String? = nil, bundle: Bundle = .clackableDefault) {
        guard let resolvedURL = Self.resolveURL(for: resource, withExtension: fileExtension, bundle: bundle) else {
            return nil
        }
        self.init(url: resolvedURL, identifier: [resource, fileExtension].compactMap { $0 }.joined(separator: "."))
    }
}

private extension SoundClip {
    static func resolveURL(for resource: String, withExtension fileExtension: String?, bundle: Bundle) -> URL? {
        if let directMatch = bundle.url(forResource: resource, withExtension: fileExtension) {
            return directMatch
        }

        guard let rootURL = bundle.resourceURL else {
            return nil
        }

        let expectedFilename = [resource, fileExtension].compactMap { $0 }.joined(separator: ".")
        let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        while let nextURL = enumerator?.nextObject() as? URL {
            if nextURL.lastPathComponent == expectedFilename {
                return nextURL
            }
        }

        return nil
    }
}
