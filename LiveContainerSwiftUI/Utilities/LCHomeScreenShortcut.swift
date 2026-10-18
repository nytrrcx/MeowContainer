import UIKit

enum LCHomeScreenShortcut {
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

}
