import UIKit

extension UIView {
    static let activeAlpha: CGFloat = 1
    static let deactivatedAlpha: CGFloat = 0.5
    
    
    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.compactMap { $0 }
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
    
    
    func setActiveNonAnimated(_ active: Bool) {
        self.alpha = active ? UIView.activeAlpha : UIView.deactivatedAlpha
        self.isUserInteractionEnabled = active
    }
    
    
    func setHidden(_ blocked: Bool, animated: Bool = true) {
        if !blocked {
            isHidden = false
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            self.alpha = blocked ? 0 : 1
        }) { _ in
            self.isHidden = blocked
        }
    }
    
    func rotate(withDuration: TimeInterval, clockwise: Bool) {
        UIView.animate(withDuration: withDuration) {
            self.transform = self.transform.rotated(by: clockwise ? CGFloat.pi : -(CGFloat.pi * 0.999))
        }
    }
    
    
    static func animateButtonClick(_ views: [UIView]) {
        UIView.animate(withDuration: 0.2, animations: {
            let transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
            views.forEach { $0.transform = transform }
        }) { success in
            UIView.animate(withDuration: 0.2) {
                views.forEach { $0.transform = CGAffineTransform.identity }
            }
        }
    }
    
    
    func opacityAnimationBlink(with duration: Double = 0.2, to alpha: CGFloat = 0.5, completion: (() -> ())? = nil) {
        let previousAlpha = self.alpha
        
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
                self.alpha = previousAlpha
            }) { _ in
                completion?()
            }
        }
    }
    
    
    final func topSafeAnchorIOS11(_ vc: UIViewController) -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return vc.topLayoutGuide.bottomAnchor
        }
    }
    
    final func bottomSafeAnchorIOS11(_ vc: UIViewController) -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return vc.bottomLayoutGuide.topAnchor
        }
    }
    
    
    final var leadingA: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leadingAnchor
        } else {
            return leadingAnchor
        }
    }
    
    
    final var trailingA: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.trailingAnchor
        } else {
            return trailingAnchor
        }
    }
    
    
    var safeAreaBottomInset: CGFloat {
        if #available(iOS 11, *) {
            return safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    
    final func copySuperviewSizeConstraints(_ superView: UIView, in vc: UIViewController? = nil) {
        if let _vc = vc {
            topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superView.bottomSafeAnchorIOS11(_vc)).isActive = true
        } else {
            topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
            centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
            centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        }
        
        trailingAnchor.constraint(equalTo: superView.trailingA).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingA).isActive = true
    }
    
    
    static func separatorNoConstraints(_ parent: UIView, color: UIColor, width: CGFloat = 1) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = width * 0.1
        view.layer.borderColor = color.cgColor
        view.backgroundColor = color
        parent.addSubview(view)
        
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        return view
    }
    
    
    static func separator(_ parent: UIView, color: UIColor, _ height: NSLayoutDimension,
                          _ inset: CGFloat, width: CGFloat = 1, multiplier: CGFloat = 1) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = width * 0.1
        view.layer.borderColor = color.cgColor
        view.backgroundColor = color
        parent.addSubview(view)
        
        view.centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: inset).isActive = true
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.heightAnchor.constraint(equalTo: height, multiplier: multiplier).isActive = true
        return view
    }
    
    
    static func separator(_ parent: UIView, color: UIColor, _ height: CGFloat,
                          _ inset: CGFloat, width: CGFloat = 1) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = width * 0.1
        view.layer.borderColor = color.cgColor
        view.backgroundColor = color
        parent.addSubview(view)
        
        view.centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: inset).isActive = true
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    @discardableResult
    func registerClickAreaAsSubview(in target: Any, with action: Selector, expandedArea: CGFloat = 10) -> UIView {
        return _registerExtendedClickArea(in: target, inside: self, with: action, expandedArea: expandedArea)
    }
    
    
    @discardableResult
    func registerExtendedClickArea(in target: UIView, with action: Selector, expandedArea: CGFloat = 10) -> UIView {
        return _registerExtendedClickArea(in: target, inside: target, with: action, expandedArea: expandedArea)
    }
    
    
    @discardableResult
    func registerExtendedClickArea(in target: UIViewController, with action: Selector, expandedArea: CGFloat = 10) -> UIView {
        return _registerExtendedClickArea(in: target, inside: target.view, with: action, expandedArea: expandedArea)
    }
    
    
    fileprivate func _registerExtendedClickArea(in target: Any, inside parent: UIView,
                                                with action: Selector, expandedArea: CGFloat = 10) -> UIView {
        let tap = UITapGestureRecognizer()
        tap.addTarget(target, action: action)
        
        let clickArea = UIView()
        clickArea.translatesAutoresizingMaskIntoConstraints = false
        clickArea.isUserInteractionEnabled = true
        clickArea.addGestureRecognizer(tap)
        parent.addSubview(clickArea)
        
        let constraints = [
            clickArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -expandedArea),
            clickArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: expandedArea),
            clickArea.topAnchor.constraint(equalTo: topAnchor, constant: -expandedArea),
            clickArea.bottomAnchor.constraint(equalTo: bottomAnchor, constant: expandedArea)
        ]
        
        NSLayoutConstraint.activate(constraints)
        return clickArea
    }
}


protocol HighlightableView: class {
    var highlightAnimationRunning: Bool { set get }
    func runSelectColorAnimation(_ color: UIColor)
    func changeColorOnUnhighlight(_ color: UIColor)
}

extension HighlightableView where Self: UIView {
    func runSelectColorAnimation(_ color: UIColor = .lightGray) {
        if !highlightAnimationRunning {
            var previousCellColor: UIColor? = UIColor.clear
            if let cell = self as? UITableViewCell {
                previousCellColor = cell.contentView.backgroundColor
                cell.contentView.backgroundColor = .clear
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = color
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = UIColor.white
                    
                    if let cell = self as? UITableViewCell {
                        cell.contentView.backgroundColor = previousCellColor
                    }
                }
            }
        }
    }
    
    
    func changeColorOnUnhighlight(_ previousColor: UIColor = .lightGray) {
        var previousCellColor: UIColor? = UIColor.clear
        if let cell = self as? UITableViewCell {
            previousCellColor = cell.contentView.backgroundColor
            cell.contentView.backgroundColor = previousColor
        }
        
        highlightAnimationRunning = true
        backgroundColor = previousColor
        
        UIView.animate(withDuration: 0.4, animations: {
            if let cell = self as? UITableViewCell {
                cell.contentView.backgroundColor = previousCellColor
            }
            
            self.backgroundColor = UIColor.white
        }) { _ in
            self.highlightAnimationRunning = false
        }
    }
}


extension UIViewController {
    func setupPopover(view: UIView) {
        if let popover = popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
    }
}
