

import UIKit


class ShowableObjectSearchCell<T>: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    var rowAction: SearchRowAction? {
        didSet {
            if let _action = rowAction {
                updateData(_action)
            }
        }
    }
    
    open class var identifier: String { return "ShowableObjectSearchCell" }
    
    open var canBeHiglighted: Bool { return false }
    
    open func setupViews() { }
    
    open func updateData(_ action: SearchRowAction) { }
    
    open func didUnhiglight() { }
    
    open func didSelect() { }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if canBeHiglighted {
            super.setHighlighted(highlighted, animated: animated)
        }
    }
}
