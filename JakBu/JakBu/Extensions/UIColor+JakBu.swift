import UIKit

extension UIColor {

    // MARK: - Background Colors

    /// Dark gradient background top color (#1e2a3f)
    static let jakbuBackgroundTop = UIColor(red: 0x1e/255.0, green: 0x2a/255.0, blue: 0x3f/255.0, alpha: 1.0)

    /// Dark gradient background middle color (#1a2332)
    static let jakbuBackgroundMiddle = UIColor(red: 0x1a/255.0, green: 0x23/255.0, blue: 0x32/255.0, alpha: 1.0)

    /// Dark gradient background bottom color (#0f1520)
    static let jakbuBackgroundBottom = UIColor(red: 0x0f/255.0, green: 0x15/255.0, blue: 0x20/255.0, alpha: 1.0)

    // MARK: - Accent Colors

    /// JakBu title gradient start color (#6b9bd8)
    static let jakbuTitleStart = UIColor(red: 0x6b/255.0, green: 0x9b/255.0, blue: 0xd8/255.0, alpha: 1.0)

    /// JakBu title gradient end color (#5b8dd5)
    static let jakbuTitleEnd = UIColor(red: 0x5b/255.0, green: 0x8d/255.0, blue: 0xd5/255.0, alpha: 1.0)

    /// Selected item gradient start color (#5b8dd5)
    static let jakbuSelectedStart = UIColor(red: 0x5b/255.0, green: 0x8d/255.0, blue: 0xd5/255.0, alpha: 1.0)

    /// Selected item gradient end color (#4a7bc0)
    static let jakbuSelectedEnd = UIColor(red: 0x4a/255.0, green: 0x7b/255.0, blue: 0xc0/255.0, alpha: 1.0)

    // MARK: - Text Colors

    /// Primary text color (white)
    static let jakbuTextPrimary = UIColor.white

    /// Secondary text color (white with 80% opacity)
    static let jakbuTextSecondary = UIColor.white.withAlphaComponent(0.8)

    /// Tertiary text color (white with 60% opacity)
    static let jakbuTextTertiary = UIColor.white.withAlphaComponent(0.6)

    /// Quaternary text color (white with 50% opacity)
    static let jakbuTextQuaternary = UIColor.white.withAlphaComponent(0.5)

    /// Placeholder text color (white with 40% opacity)
    static let jakbuTextPlaceholder = UIColor.white.withAlphaComponent(0.4)

    // MARK: - Card Colors

    /// Card background with glassmorphism effect (white with 10% opacity)
    static let jakbuCardBackground = UIColor.white.withAlphaComponent(0.1)

    /// Card background secondary (white with 5% opacity)
    static let jakbuCardBackgroundSecondary = UIColor.white.withAlphaComponent(0.05)

    /// Card border color (white with 10% opacity)
    static let jakbuCardBorder = UIColor.white.withAlphaComponent(0.1)

    // MARK: - Helper Methods

    /// Creates a vertical gradient layer
    static func jakbuGradientLayer(colors: [UIColor], frame: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = frame
        return gradientLayer
    }

    /// Creates a horizontal gradient layer
    static func jakbuHorizontalGradientLayer(colors: [UIColor], frame: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = frame
        return gradientLayer
    }
}
