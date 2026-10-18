import CryptoKit
import UIKit

enum LCHomeScreenShortcut {
    // Publish docs/ from this fork with GitHub Pages before distributing the build.
    static let pageURL = URL(string: "https://nytrrcx.github.io/MeowContainer/shortcut/")!

    static func launchURL(for appInfo: LCAppInfo, containerID: String?) -> URL? {
        guard let bundlePath = appInfo.relativeBundlePath, !bundlePath.isEmpty else { return nil }
        var components = URLComponents()
        components.scheme = LCUtils.appUrlScheme()
        components.host = "livecontainer-launch"
        components.queryItems = [URLQueryItem(name: "bundle-name", value: bundlePath)]
        if let containerID {
            components.queryItems?.append(URLQueryItem(name: "container-folder-name", value: containerID))
        }
        return components.url
    }

    static func pageURL(for appInfo: LCAppInfo, containerID: String?, darkIcon: Bool) throws -> URL {
        guard let launchURL = launchURL(for: appInfo, containerID: containerID),
              let icon = appInfo.generateLiveContainerWrappedIcon(with: darkIcon ? .Dark : .Light) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        // Keep the URL small while preserving the app's own artwork.
        var imageData: Data?
        let iconSizes: [CGFloat] = [180, 120, 80, 60]
        for size in iconSizes {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            let bounds = CGRect(x: 0, y: 0, width: size, height: size)
            let image = UIGraphicsImageRenderer(size: bounds.size, format: format).image { _ in
                UIColor.white.setFill()
                UIRectFill(bounds)
                icon.draw(in: bounds)
            }
            imageData = image.pngData()
            if let imageData, imageData.count <= 12_000 { break }
        }
        guard let imageData else { throw CocoaError(.fileWriteUnknown) }

        let payload: [String: Any] = [
            "v": 1,
            "name": String((appInfo.displayName() ?? "MeowContainer").prefix(512)),
            "launchURL": launchURL.absoluteString,
            "icon": imageData.base64EncodedString()
        ]
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        let fragment = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        var components = URLComponents(url: pageURL, resolvingAgainstBaseURL: false)!
        // Distinct start URLs keep different apps/containers separate on iOS.
        let identifier = SHA256.hash(data: Data(launchURL.absoluteString.utf8))
            .prefix(16).map { String(format: "%02x", $0) }.joined()
        components.queryItems = [URLQueryItem(name: "id", value: identifier)]
        // Fragments stay in the browser; the icon and launch URL aren't sent to Pages.
        components.fragment = "v1.\(fragment)"
        guard let url = components.url else { throw CocoaError(.fileWriteUnknown) }
        return url
    }
}
