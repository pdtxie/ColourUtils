#if canImport(UIKit)
import UIKit

public extension UIColor {
    convenience init(hex: String) {
        if let c = ColourUtils.getRGB(hex: hex) {
            self.init(red: c.x, green: c.y, blue: c.z, alpha: 1.0)
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        }
    }
}
#endif
