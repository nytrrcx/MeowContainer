import SwiftUI
import UIKit

struct LCAppearance: DynamicProperty {
    @AppStorage("MCCatEars", store: LCUtils.appGroupUserDefault) var catEars = true
    @AppStorage("MCCatTabBar", store: LCUtils.appGroupUserDefault) var catTabBar = true
    @AppStorage("MCPastelCards", store: LCUtils.appGroupUserDefault) var pastelCards = false
    @AppStorage("MCPastelPalette", store: LCUtils.appGroupUserDefault) var paletteStorage = LCAppearance.defaultPalette
    @AppStorage("MCCustomBackground", store: LCUtils.appGroupUserDefault) var customBackground = false
    @AppStorage("MCBackgroundColor", store: LCUtils.appGroupUserDefault) var backgroundStorage = "#FFF7FB"

    static let defaultPalette = "#FCE7F3,#EDE9FE,#FFEDD5,#DCFCE7"
    static let presets: [(name: String, colors: String)] = [
        ("lc.appearance.sakura", defaultPalette),
        ("lc.appearance.lavender", "#EDE9FE,#DDD6FE,#F3E8FF,#FAE8FF"),
        ("lc.appearance.peach", "#FFEDD5,#FFE4E6,#FEF3C7,#FCE7F3")
    ]

    var palette: [LCThemeColor] {
        let entries = paletteStorage.split(separator: ",", omittingEmptySubsequences: false)
        let colors = entries.compactMap { LCThemeColor(hex: String($0)) }
        guard entries.count == 4, colors.count == 4 else {
            return Self.defaultPalette.split(separator: ",").compactMap { LCThemeColor(hex: String($0)) }
        }
        return colors
    }

    var background: LCThemeColor {
        LCThemeColor(hex: backgroundStorage) ?? LCThemeColor(red: 1, green: 0.969, blue: 0.984)
    }

    var preferredColorScheme: ColorScheme? {
        customBackground ? (background.prefersDarkText ? .light : .dark) : nil
    }

    var accentColor: Color {
        guard customBackground else { return Color("AccentColor") }
        let pink = LCThemeColor(red: 0.859, green: 0.153, blue: 0.467)
        let target = background.prefersDarkText
            ? LCThemeColor(red: 0, green: 0, blue: 0)
            : LCThemeColor(red: 1, green: 1, blue: 1)
        for step in 0...10 {
            let candidate = pink.mixed(with: target, amount: Double(step) / 10)
            if candidate.contrastRatio(with: background) >= 4.5 {
                return Color(uiColor: candidate.uiColor)
            }
        }
        return Color(uiColor: target.uiColor)
    }

    func pastelColor(for identifier: String) -> LCThemeColor? {
        guard pastelCards else { return nil }
        // Swift's Hasher is randomized between launches; keep app colors stable instead.
        let hash = identifier.utf8.reduce(UInt64(14695981039346656037)) { ($0 ^ UInt64($1)) &* 1099511628211 }
        return palette[Int(hash % 4)]
    }

    func setPaletteColor(_ color: Color, at index: Int) {
        guard (0..<4).contains(index) else { return }
        var colors = palette
        colors[index] = LCThemeColor(color: color)
        paletteStorage = colors.map(\.hex).joined(separator: ",")
    }
}

struct LCThemeColor: Equatable {
    let red: Double
    let green: Double
    let blue: Double

    init(red: Double, green: Double, blue: Double) {
        self.red = min(max(red, 0), 1)
        self.green = min(max(green, 0), 1)
        self.blue = min(max(blue, 0), 1)
    }

    init?(hex: String) {
        let digits = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
        self.init(red: Double((value >> 16) & 255) / 255,
                  green: Double((value >> 8) & 255) / 255,
                  blue: Double(value & 255) / 255)
    }

    init(color: Color) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.init(red: Double(red), green: Double(green), blue: Double(blue))
    }

    var hex: String {
        String(format: "#%02X%02X%02X", Int((red * 255).rounded()), Int((green * 255).rounded()), Int((blue * 255).rounded()))
    }

    var uiColor: UIColor {
        UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }

    private var luminance: Double {
        func linear(_ value: Double) -> Double {
            value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }

    var prefersDarkText: Bool { luminance > 0.179 }
    var foreground: UIColor { prefersDarkText ? .black : .white }

    func contrastRatio(with other: LCThemeColor) -> Double {
        (max(luminance, other.luminance) + 0.05) / (min(luminance, other.luminance) + 0.05)
    }

    func mixed(with other: LCThemeColor, amount: Double) -> LCThemeColor {
        LCThemeColor(red: red * (1 - amount) + other.red * amount,
                     green: green * (1 - amount) + other.green * amount,
                     blue: blue * (1 - amount) + other.blue * amount)
    }
}

struct LCPastelCardColors {
    let background: UIColor
    let text: UIColor
    let button: UIColor
    let buttonText: UIColor

    init(color: LCThemeColor, isDark: Bool) {
        let surface = isDark
            ? color.mixed(with: LCThemeColor(red: 0.11, green: 0.08, blue: 0.11), amount: 0.75)
            : color
        let button = isDark
            ? color.mixed(with: LCThemeColor(red: 1, green: 1, blue: 1), amount: 0.35)
            : color.mixed(with: LCThemeColor(red: 0, green: 0, blue: 0), amount: 0.55)
        self.background = surface.uiColor
        self.text = surface.foreground
        self.button = button.uiColor
        self.buttonText = button.foreground
    }
}

extension View {
    func meowBackground() -> some View {
        modifier(LCAppBackgroundModifier())
    }
}

private struct LCAppBackgroundModifier: ViewModifier {
    private var appearance = LCAppearance()

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            background(content.scrollContentBackground(appearance.customBackground ? .hidden : .automatic))
        } else {
            background(content)
        }
    }

    private func background<V: View>(_ content: V) -> some View {
        content.background {
            if appearance.customBackground {
                Color(uiColor: appearance.background.uiColor).ignoresSafeArea()
            }
        }
        .background(LCNavigationBackground(color: appearance.customBackground ? appearance.background.uiColor : nil))
    }
}

private struct LCNavigationBackground: UIViewControllerRepresentable {
    let color: UIColor?

    func makeUIViewController(context: Context) -> BackgroundController {
        BackgroundController()
    }

    func updateUIViewController(_ controller: BackgroundController, context: Context) {
        controller.color = color
        controller.applyBackground()
    }

    final class BackgroundController: UIViewController {
        var color: UIColor?
        private weak var configuredNavigationController: UINavigationController?
        private var originalBackground: UIColor?
        private let legacyBackgrounds = NSMapTable<UITableView, UIColor>(keyOptions: .weakMemory, valueOptions: .strongMemory)

        override func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = false
            view.backgroundColor = .clear
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            applyBackground()
        }

        func applyBackground() {
            if #unavailable(iOS 16.0) {
                updateLegacyListBackgrounds()
            }
            guard let navigationController else { return }
            if configuredNavigationController !== navigationController {
                guard color != nil else { return }
                configuredNavigationController = navigationController
                originalBackground = navigationController.view.backgroundColor
            }
            navigationController.view.backgroundColor = color ?? originalBackground
        }

        private func updateLegacyListBackgrounds() {
            guard color != nil else {
                for case let table as UITableView in legacyBackgrounds.keyEnumerator() {
                    table.backgroundColor = legacyBackgrounds.object(forKey: table)
                }
                legacyBackgrounds.removeAllObjects()
                return
            }
            guard let root = parent?.view else { return }
            func clearBackground(in view: UIView) {
                if let table = view as? UITableView {
                    if legacyBackgrounds.object(forKey: table) == nil {
                        legacyBackgrounds.setObject(table.backgroundColor ?? .clear, forKey: table)
                    }
                    table.backgroundColor = .clear
                } else {
                    view.subviews.forEach { clearBackground(in: $0) }
                }
            }
            clearBackground(in: root)
        }
    }
}
