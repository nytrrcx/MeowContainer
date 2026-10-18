import SwiftUI
import UIKit

// Drawn in points so the decorations stay sharp at every screen scale.
final class LCCatEarsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        contentMode = .redraw
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.scaleBy(x: bounds.width / 60, y: bounds.height / 18)
        let isDark = traitCollection.userInterfaceStyle == .dark
        let outer = isDark
            ? UIColor(red: 0.69, green: 0.38, blue: 0.53, alpha: 1)
            : UIColor(red: 0.98, green: 0.73, blue: 0.83, alpha: 1)
        let inner = isDark
            ? UIColor(red: 1, green: 0.68, blue: 0.81, alpha: 1)
            : UIColor(red: 0.81, green: 0.27, blue: 0.49, alpha: 1)

        for mirrored in [false, true] {
            context.saveGState()
            if mirrored {
                context.translateBy(x: 60, y: 0)
                context.scaleBy(x: -1, y: 1)
            }
            let ear = UIBezierPath()
            ear.move(to: CGPoint(x: 4, y: 18))
            ear.addLine(to: CGPoint(x: 5, y: 3))
            ear.addQuadCurve(to: CGPoint(x: 8, y: 2), controlPoint: CGPoint(x: 5, y: 0))
            ear.addLine(to: CGPoint(x: 25, y: 18))
            ear.close()
            outer.setFill()
            ear.fill()

            let inside = UIBezierPath()
            inside.move(to: CGPoint(x: 9, y: 7))
            inside.addLine(to: CGPoint(x: 8, y: 16))
            inside.addLine(to: CGPoint(x: 19, y: 16))
            inside.close()
            inner.setFill()
            inside.fill()
            context.restoreGState()
        }
    }
}

struct LCCatEars: UIViewRepresentable {
    func makeUIView(context: Context) -> LCCatEarsView { LCCatEarsView() }
    func updateUIView(_ uiView: LCCatEarsView, context: Context) {}
}

enum LCMeowTabIcon: Int, CaseIterable {
    case sources, apps, tweaks, settings

    var image: UIImage { Self.images[rawValue] }

    private static let images: [UIImage] = allCases.map { icon in
        UIGraphicsImageRenderer(size: CGSize(width: 26, height: 26)).image { renderer in
            let context = renderer.cgContext
            context.translateBy(x: 1, y: 1)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setFillColor(UIColor.black.cgColor)
            context.setLineWidth(1.8)
            context.setLineCap(.round)
            context.setLineJoin(.round)

            switch icon {
            case .sources:
                // A cat peeking out of a cardboard box.
                context.move(to: CGPoint(x: 6, y: 10))
                context.addLine(to: CGPoint(x: 6, y: 3))
                context.addLine(to: CGPoint(x: 10, y: 6))
                context.addQuadCurve(to: CGPoint(x: 14, y: 6), control: CGPoint(x: 12, y: 5))
                context.addLine(to: CGPoint(x: 18, y: 3))
                context.addLine(to: CGPoint(x: 18, y: 10))
                context.strokePath()
                context.move(to: CGPoint(x: 3, y: 10))
                context.addLine(to: CGPoint(x: 12, y: 13))
                context.addLine(to: CGPoint(x: 21, y: 10))
                context.addLine(to: CGPoint(x: 21, y: 20))
                context.addLine(to: CGPoint(x: 12, y: 23))
                context.addLine(to: CGPoint(x: 3, y: 20))
                context.closePath()
                context.move(to: CGPoint(x: 12, y: 13))
                context.addLine(to: CGPoint(x: 12, y: 23))
                context.strokePath()
                context.fillEllipse(in: CGRect(x: 8, y: 8, width: 1.8, height: 1.8))
                context.fillEllipse(in: CGRect(x: 14.2, y: 8, width: 1.8, height: 1.8))

            case .apps:
                // Four toe pads and a soft, heart-shaped paw pad.
                for pad in [CGRect(x: 1, y: 7, width: 4.5, height: 6),
                            CGRect(x: 6, y: 2, width: 5, height: 7),
                            CGRect(x: 13, y: 2, width: 5, height: 7),
                            CGRect(x: 18.5, y: 7, width: 4.5, height: 6)] {
                    context.fillEllipse(in: pad)
                }
                context.move(to: CGPoint(x: 12, y: 11))
                context.addCurve(to: CGPoint(x: 3.5, y: 20), control1: CGPoint(x: 8, y: 10), control2: CGPoint(x: 1, y: 17))
                context.addCurve(to: CGPoint(x: 12, y: 21), control1: CGPoint(x: 5, y: 24), control2: CGPoint(x: 9, y: 21))
                context.addCurve(to: CGPoint(x: 20.5, y: 20), control1: CGPoint(x: 15, y: 21), control2: CGPoint(x: 19, y: 24))
                context.addCurve(to: CGPoint(x: 12, y: 11), control1: CGPoint(x: 23, y: 17), control2: CGPoint(x: 16, y: 10))
                context.fillPath()

            case .tweaks:
                // A ball of yarn, including the loose end.
                context.strokeEllipse(in: CGRect(x: 2, y: 2, width: 18, height: 18))
                context.move(to: CGPoint(x: 5, y: 5))
                context.addCurve(to: CGPoint(x: 17, y: 18), control1: CGPoint(x: 12, y: 6), control2: CGPoint(x: 16, y: 11))
                context.move(to: CGPoint(x: 9, y: 2))
                context.addCurve(to: CGPoint(x: 20, y: 13), control1: CGPoint(x: 15, y: 4), control2: CGPoint(x: 19, y: 7))
                context.move(to: CGPoint(x: 2, y: 11))
                context.addQuadCurve(to: CGPoint(x: 11, y: 20), control: CGPoint(x: 8, y: 13))
                context.move(to: CGPoint(x: 3, y: 15))
                context.addQuadCurve(to: CGPoint(x: 15, y: 3), control: CGPoint(x: 5, y: 5))
                context.move(to: CGPoint(x: 17, y: 18))
                context.addCurve(to: CGPoint(x: 23, y: 21), control1: CGPoint(x: 18, y: 25), control2: CGPoint(x: 20, y: 18))
                context.strokePath()

            case .settings:
                // A whiskered cat face.
                context.move(to: CGPoint(x: 4, y: 12))
                context.addLine(to: CGPoint(x: 4, y: 3))
                context.addLine(to: CGPoint(x: 9, y: 7))
                context.addQuadCurve(to: CGPoint(x: 15, y: 7), control: CGPoint(x: 12, y: 5))
                context.addLine(to: CGPoint(x: 20, y: 3))
                context.addLine(to: CGPoint(x: 20, y: 12))
                context.addCurve(to: CGPoint(x: 12, y: 22), control1: CGPoint(x: 24, y: 18), control2: CGPoint(x: 18, y: 22))
                context.addCurve(to: CGPoint(x: 4, y: 12), control1: CGPoint(x: 6, y: 22), control2: CGPoint(x: 0, y: 18))
                context.move(to: CGPoint(x: 1, y: 14))
                context.addLine(to: CGPoint(x: 6, y: 15))
                context.move(to: CGPoint(x: 1, y: 19))
                context.addLine(to: CGPoint(x: 6, y: 18))
                context.move(to: CGPoint(x: 18, y: 15))
                context.addLine(to: CGPoint(x: 23, y: 14))
                context.move(to: CGPoint(x: 18, y: 18))
                context.addLine(to: CGPoint(x: 23, y: 19))
                context.strokePath()
                context.fillEllipse(in: CGRect(x: 7, y: 11, width: 2.5, height: 3))
                context.fillEllipse(in: CGRect(x: 14.5, y: 11, width: 2.5, height: 3))
                context.move(to: CGPoint(x: 10, y: 16))
                context.addLine(to: CGPoint(x: 14, y: 16))
                context.addLine(to: CGPoint(x: 12, y: 18))
                context.fillPath()
            }
        }.withRenderingMode(.alwaysTemplate)
    }
}
