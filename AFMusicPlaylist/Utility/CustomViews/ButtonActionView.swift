
import UIKit

class ButtonActionView: UIView, HighlightableView {
    var highlightAnimationRunning = false
    
    let label: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.systemFont(ofSize: 17.ifIpad(20))
        return label
    }()
    
    
    private let arrow: UIImageView = {
        let arrow = UIImageView(image: UIImage(named: "ic_keyboard_arrow_left_48pt"))
        arrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        arrow.contentMode = .scaleAspectFit
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        return arrow
    }()
    
    
    private var offset: CGFloat = 0
    private var iconMultiplier: CGFloat = 0.8
    
    init(offset: CGFloat, iconMultiplier: CGFloat = 0.8) {
        self.offset = offset
        self.iconMultiplier = iconMultiplier
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    private func setupViews() {
        addSubview(label)
        addSubview(arrow)
        
        label.leadingAnchor.constraint(equalTo: leadingA, constant: offset).isActive = true
        label.trailingAnchor.constraint(equalTo: arrow.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        arrow.trailingAnchor.constraint(equalTo: trailingA, constant: -offset).isActive = true
        arrow.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        arrow.heightAnchor.constraint(equalTo: heightAnchor, multiplier: iconMultiplier).isActive = true
        arrow.widthAnchor.constraint(equalTo: heightAnchor, multiplier: iconMultiplier).isActive = true
    }
}
