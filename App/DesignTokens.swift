import SwiftUI
import UIKit

// MARK: - Color(hex:) Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(light lightHex: String, dark darkHex: String) {
        self.init(uiColor: UIColor(
            light: UIColor(Color(hex: lightHex)),
            dark: UIColor(Color(hex: darkHex))
        ))
    }
}

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}

// MARK: - Design Tokens
enum DesignTokens {
    // MARK: Colors — Semantic, Light + Dark
    /// Warm terracotta accent — professional yet approachable
    static let accent = Color(light: "E06C4A", dark: "E88D6A")
    
    /// Light accent for selection/highlight backgrounds
    static let accentLight = Color(light: "FFF0EB", dark: "3D2820")
    
    /// Dark accent for pressed states
    static let accentDark = Color(light: "C45536", dark: "C97555")
    
    /// Main background — warm white / warm dark
    static let background = Color(light: "FAFAF8", dark: "1C1C1E")
    
    /// Elevated surfaces (cards, sheets)
    static let surface = Color(light: "FFFFFF", dark: "2C2C2E")
    
    /// Primary text — near-black / near-white
    static let textPrimary = Color(light: "1A1A1A", dark: "F2F2F7")
    
    /// Secondary text — muted warm gray
    static let textSecondary = Color(light: "6B6B6B", dark: "8E8E93")
    
    /// Tertiary text — faint
    static let textTertiary = Color(light: "999999", dark: "636366")
    
    /// Hairline borders / dividers
    static let border = Color(light: "E5E5E5", dark: "38383A")
    
    // MARK: Semantic Status Colors (map to existing SemanticTint)
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")
    static let info = Color.accentColor  // Uses accent
    
    // MARK: Spacing (8pt Grid)
    static let spaceXS: CGFloat = 4
    static let spaceS: CGFloat = 8
    static let spaceM: CGFloat = 16
    static let spaceL: CGFloat = 24
    static let spaceXL: CGFloat = 32
    static let spaceXXL: CGFloat = 48
    
    // MARK: Corner Radius
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 28  // Sheet corner
    
    // MARK: Typography Helpers
    static let displayFont = "New York"  // Serif for headings (Things-style)
    static let bodyFont = "SF Pro"
}

#Preview("Design Tokens") {
    VStack(spacing: DesignTokens.spaceL) {
        // Color swatches
        VStack(alignment: .leading, spacing: DesignTokens.spaceS) {
            Text("Colors").font(.headline)
            HStack(spacing: DesignTokens.spaceS) {
                ColorSwatch(name: "Accent", color: DesignTokens.accent)
                ColorSwatch(name: "Background", color: DesignTokens.background)
                ColorSwatch(name: "Surface", color: DesignTokens.surface)
                ColorSwatch(name: "Border", color: DesignTokens.border)
            }
        }
        
        VStack(alignment: .leading, spacing: DesignTokens.spaceS) {
            Text("Semantic").font(.headline)
            HStack(spacing: DesignTokens.spaceS) {
                ColorSwatch(name: "Success", color: DesignTokens.success)
                ColorSwatch(name: "Warning", color: DesignTokens.warning)
                ColorSwatch(name: "Error", color: DesignTokens.error)
                ColorSwatch(name: "Info", color: DesignTokens.info)
            }
        }
        
        VStack(alignment: .leading, spacing: DesignTokens.spaceS) {
            Text("Text").font(.headline)
            HStack(spacing: DesignTokens.spaceS) {
                ColorSwatch(name: "Primary", color: DesignTokens.textPrimary)
                ColorSwatch(name: "Secondary", color: DesignTokens.textSecondary)
                ColorSwatch(name: "Tertiary", color: DesignTokens.textTertiary)
            }
        }
        
        // Spacing demo
        VStack(alignment: .leading, spacing: DesignTokens.spaceS) {
            Text("Spacing (8pt grid)").font(.headline)
            HStack(spacing: DesignTokens.spaceS) {
                SpacingBox(label: "XS", value: DesignTokens.spaceXS)
                SpacingBox(label: "S", value: DesignTokens.spaceS)
                SpacingBox(label: "M", value: DesignTokens.spaceM)
                SpacingBox(label: "L", value: DesignTokens.spaceL)
                SpacingBox(label: "XL", value: DesignTokens.spaceXL)
            }
        }
        
        // Radius demo
        VStack(alignment: .leading, spacing: DesignTokens.spaceS) {
            Text("Corner Radius").font(.headline)
            HStack(spacing: DesignTokens.spaceS) {
                RadiusBox(label: "S", radius: DesignTokens.radiusS)
                RadiusBox(label: "M", radius: DesignTokens.radiusM)
                RadiusBox(label: "L", radius: DesignTokens.radiusL)
                RadiusBox(label: "XL", radius: DesignTokens.radiusXL)
            }
        }
    }
    .padding(DesignTokens.spaceM)
    .background(DesignTokens.background)
}

private struct ColorSwatch: View {
    let name: String
    let color: Color
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: DesignTokens.radiusS)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.radiusS)
                        .stroke(DesignTokens.border, lineWidth: 1)
                )
            Text(name)
                .font(.caption)
                .foregroundStyle(DesignTokens.textSecondary)
        }
    }
}

private struct SpacingBox: View {
    let label: String
    let value: CGFloat
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: DesignTokens.radiusS)
                .fill(DesignTokens.accent.opacity(0.1))
                .frame(width: 44, height: value)
            Text(label)
                .font(.caption)
                .foregroundStyle(DesignTokens.textSecondary)
        }
    }
}

private struct RadiusBox: View {
    let label: String
    let radius: CGFloat
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: radius)
                .fill(DesignTokens.accent.opacity(0.1))
                .frame(width: 60, height: 60)
            Text(label)
                .font(.caption)
                .foregroundStyle(DesignTokens.textSecondary)
        }
    }
}