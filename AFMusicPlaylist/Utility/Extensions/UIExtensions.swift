import UIKit


extension UILabel {
    class func defaultInit() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }
}


class CorneredButton: UIButton {
    private var radius: CGFloat
    private var shadow: Bool
    
    
    init(shadow: Bool, radius: CGFloat = 0.5) {
        self.radius = radius
        self.shadow = shadow
        super.init(frame: CGRect.zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.width * radius
        
        if shadow {
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.shadowRadius = 5
        }
    }
}


class OffsetButton: UIButton {
    private var offset: CGFloat
    
    
    init(offset: CGFloat = 5) {
        self.offset = offset
        super.init(frame: CGRect.zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + offset,
                      y: bounds.minY + offset,
                      width: bounds.width - offset * 2,
                      height: bounds.height - offset * 2)
    }
}

class CorneredUIView: UIView {
    private var radius: CGFloat

    
    init(radius: CGFloat = 0.5) {
        self.radius = radius
        super.init(frame: CGRect.zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.width * radius
    }
}


class CorneredUIImageView: UIImageView {
    private var radius: CGFloat

    
    init(radius: CGFloat = 0.5) {
        self.radius = radius
        super.init(frame: CGRect.zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.width * radius
    }
}




extension NSLayoutConstraint {
    func lowerPriority() {
        priority = UILayoutPriority(rawValue: 999)
        isActive = true
    }
}


extension UIColor {
    convenience init<T: SignedInteger>(red: T, green: T, blue: T, alpha: CGFloat = 1) {
        self.init(red: CGFloat(red) / 255,
                  green: CGFloat(green) / 255,
                  blue: CGFloat(blue) / 255, alpha: alpha)
    }
    
    
    func defaultColorIfNotVisibile() -> UIColor {
        if CIColor(color: self).alpha == 0 {
            return .black
        }
        
        return self
    }
    
    
    static func fromAPI(intValue: Int32) -> UIColor {
        let blue = intValue & 0xFF
        let green = (intValue >> 8) & 0xFF
        let red = (intValue >> 16) & 0xFF
        let alpha = (intValue >> 24) & 0xFF
        
        return UIColor(red: red, green: green, blue: blue, alpha: (CGFloat(alpha) / 255))
    }
    
    
    func toAPIColor() -> Int32 {
        let ciColor = CIColor(color: self)
        let alpha = toInt(ciColor.alpha)
        let red = toInt(ciColor.red)
        let green = toInt(ciColor.green)
        let blue = toInt(ciColor.blue)
        
        return alpha << 24 | red << 16 | green << 8 | blue
    }
    
    
    fileprivate func toInt(_ value: CGFloat) -> Int32 {
        return Int32(value * 255)
    }
    
}
