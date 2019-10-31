
import UIKit


class AFCellData {
    var identifier: String { return AFTemplateCell.identifier }
    var rowHeightMultiplier: CGFloat { return 0.06 }
}


class AFTemplateCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    final let leadingConstant: CGFloat = 13
    final weak var presenterDelegate: PresenterDelegate?
    final var focusNextField: (() -> Bool)?
    final var onEditStart: (() -> Void)?
    
    
    final var data: AFCellData? {
        didSet {
            if let _data = data {
                setupFrom(data: _data)
            }
        }
    }
    
    
    override func setSelected(_ highlighted: Bool, animated: Bool) { }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if canBecomeHighlighted {
            super.setHighlighted(highlighted, animated: animated)
        }
    }
    
    
    // MARK: Virtual variables
    open class var identifier: String {
        return "AFTemplateCell"
    }
    
    open var canBecomeHighlighted: Bool {
        return false
    }
    
    open var shouldBackgroundColorBeChanged: Bool {
        return true
    }
    
    
    // MARK: Virtual methods
    open func setupFrom(data: AFCellData) { }
    
    open func setupViews() { }
    
    open func onCellBecameFocused() { }
    
    open func changeEditMode(canBeEdited: Bool) { }
    
    open func didSelect() { }
    
    open func didUnhighlight() { }
    
    open func willBeginScrolling() { }
    
    open func scrollAnimationDidEnd() { }
    
    private func commonInit() {
        setupViews()
        backgroundColor = AFColors.header
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = AFColors.highlightColor
    }
}
