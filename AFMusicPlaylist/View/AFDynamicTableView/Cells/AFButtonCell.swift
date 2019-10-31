
import UIKit


class AFButtonData: AFCellData {
    override var identifier: String { return AFButtonCell.identifier }
    
    enum AFButtonType {
        case list(title: String), action(title: String), valuePicker(title: String?, value: () -> String?)
    }
    
    let type: AFButtonType
    let didSelect: () -> Void
    let textColor: UIColor
    
    init(type: AFButtonType, textColor: UIColor = UIColor.white, didSelect: @escaping () -> Void) {
        self.type = type
        self.didSelect = didSelect
        self.textColor = textColor
    }
}


class AFButtonCell: AFTemplateCell, HighlightableView {
    var highlightAnimationRunning = false
    
    override class var identifier: String { return "AFButtonCell" }
    override var canBecomeHighlighted: Bool { return true }
    private var buttonView: ButtonActionView!
    private var buttonLeadingAnchor: NSLayoutConstraint!
    
    
    override func setupFrom(data: AFCellData) {
        super.setupFrom(data: data)
        guard let buttonData = data as? AFButtonData else { return }
        buttonView.label.textColor = buttonData.textColor
        buttonView.valueLabel.textColor = buttonData.textColor
        
        switch buttonData.type {
        case .action(let title):
            buttonView.type = .action
            buttonView.label.text = title
        case .list(let title):
            buttonView.type = .list
            buttonView.label.text = title
        case .valuePicker(let title, let value):
            buttonView.type = .valuePicker
            buttonView.label.text = title
            buttonView.valueLabel.text = value()
        }
        
        buttonLeadingAnchor.constant = buttonView.type == .some(.list) ? 20 : 0
    }
    
    
    override func setupViews() {
        super.setupViews()
        buttonView = ButtonActionView(offset: leadingConstant, iconMultiplier: 0.4)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonView)
        
        buttonLeadingAnchor = buttonView.leadingAnchor.constraint(equalTo: leadingA)
        buttonLeadingAnchor.isActive = true
        buttonView.trailingA.constraint(equalTo: trailingA).isActive = true
        buttonView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    
    override func didUnhighlight() {
        changeColorOnUnhighlight()
    }
    
    
    override func didSelect() {
        runSelectColorAnimation()
        (data as? AFButtonData)?.didSelect()
    }
}
