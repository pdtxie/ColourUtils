import Foundation
import Accelerate
import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

public struct ColourUtils {
    public init() { }
    
    #if canImport(UIKit)
    public static func getShadesFor(rgb c: SIMD3<Double>, n: Int) -> [UIColor] {
        var tints = [UIColor]()
        var shades = [UIColor]()
        
        let f = 1.0 / CGFloat(n)
        
        for o in stride(from: 0.0, to: 1.0, by: f) {
            let t = o + f + (1 - o - f) * c
            let s = o * c
            
            tints.append(UIColor(red: t.x, green: t.y, blue: t.z, alpha: 1.0))
            shades.append(UIColor(red: s.x, green: s.y, blue: s.z, alpha: 1.0))
        }
        
        return (shades + tints).reversed()
    }
    
    
    public static func generateRandomPleasingColour() -> UIColor {
        let base = SIMD3<Double>(CGFloat.random(in: 0...1), CGFloat.random(in: 0...1), CGFloat.random(in: 0...1))
        let (h, s, _) = getHSV(r: base.x, g: base.y, b: base.z)
        
        return UIColor(hue: h, saturation: s/2, brightness: (1+s)/2, alpha: 1.0)
    }
    #endif
    
    static func isLight(r: CGFloat, g: CGFloat, b: CGFloat, threshold: Int = 150) -> Bool {
        return (r * 0.299 + g * 0.587 + b * 0.114 > (Double(threshold) / 255))
    }
}


// MARK: - rgb
public extension ColourUtils {
    public static func getRGB(hex string: String) -> SIMD3<Double>? {
        var hex = string.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgb) else { return nil }
        
        if (string.count == 6) {
            let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(rgb & 0x0000FF) / 255.0
            
            return SIMD3(r, g, b)
        } else {
            return nil
        }
    }
}


// MARK: - hex
public extension ColourUtils {
    public static func getHex(r: CGFloat, g: CGFloat, b: CGFloat) -> String {
        hexFormat(r) + hexFormat(g) + hexFormat(b)
    }
    
    public static func getHex(rgb c: SIMD3<Double>) -> String {
        hexFormat(c.x) + hexFormat(c.y) + hexFormat(c.z)
    }
}


// MARK: - hsb/v & hsl
public extension ColourUtils {
    public static func getHSV(r: CGFloat, g: CGFloat,  b: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let v = max(r, g, b)
        let c = v - min(r, g, b)
        
        var h: CGFloat = {
            if (c == 0) { return 0 }
            
            switch (v) {
            case r: return ((g - b)/c).truncatingRemainder(dividingBy: 6)
            case g: return (b - r)/c + 2.0
            case b: return (r - g)/c + 4.0
            
            default: return 0
            }
        }()
        
        h /= 6.0
        
        
        let s: CGFloat = v == 0 ? 0 : c / v
        
        return (h, s, v)
    }
    
    
    public static func getHSL(h: CGFloat, s: CGFloat, v: CGFloat) -> (h: CGFloat, s: CGFloat, l: CGFloat) {
        let l = (2 - s) * v / 2
        var s_l = s
        
        if (l != 0) {
            if (l == 1) {
                s_l = 0
            } else if (l < 0.5) {
                s_l = s * v / (l * 2)
            } else {
                s_l = s * v / (2 - l * 2)
            }
        }

        return (h, s_l, l)
    }
}


// MARK: helper
internal func hexFormat(_ x: CGFloat) -> String {
    return String(format: "%02X", Int(x * 255))
}
