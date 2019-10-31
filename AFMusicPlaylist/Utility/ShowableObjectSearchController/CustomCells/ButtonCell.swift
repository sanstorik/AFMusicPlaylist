
import UIKit


class ButtonCell<T>: ShowableObjectSearchCell<T>, HighlightableView {
    override class var identifier: String { return "ButtonCell" }
    override var canBeHiglighted: Bool { return true }
    var highlightAnimationRunning = false
    
    private var buttonAction: SearchButtonAction {
        return rowAction as! SearchButtonAction
    }
    
    private var buttonView: ButtonActionView!
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = AFColors.header
        
        buttonView = ButtonActionView(offset: frame.width * 0.05)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonView)
        
        buttonView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        buttonView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    override func updateData(_ action: SearchRowAction) {
        buttonView.label.text = buttonAction.label
    }

    
    override func didUnhiglight() {
        changeColorOnUnhighlight()
    }
    
    
    override func didSelect() {
        buttonAction.onClick?()
        runSelectColorAnimation()
    }
}
