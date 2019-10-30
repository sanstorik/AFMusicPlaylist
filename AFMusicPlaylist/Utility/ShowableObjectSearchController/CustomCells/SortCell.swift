
import UIKit


class SortCell<T>: ShowableObjectSearchCell<T>, UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    override class var identifier: String { return "SortCell" }
    
    
    private var sortAction: SearchSortAction<T> {
        return rowAction as! SearchSortAction
    }
    
    
    private let sortLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.myriadPro(size: 17.ifIpad(20))
        return label
    }()
    
    
    private let sortCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SortTypeCell<T>.self, forCellWithReuseIdentifier: SortTypeCell<T>.identifier)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    
    private var sortingOrderSwitch: LabeledSwitch!
    
    
    override func setupViews() {
        setupSwitch()
        
        addSubview(sortLabel)
        addSubview(sortCollectionView)
        addSubview(sortingOrderSwitch)
        
        sortLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                           constant: frame.width * 0.05).isActive = true
        sortLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                            constant: -frame.width * 0.05).isActive = true
        sortLabel.topAnchor.constraint(equalTo: topAnchor, constant: frame.height * 0.35).isActive = true
        
        sortCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        sortCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        sortCollectionView.topAnchor.constraint(equalTo: sortLabel.bottomAnchor,
                                                constant: 10).isActive = true
        sortCollectionView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        
        sortCollectionView.delegate = self
        sortCollectionView.dataSource = self
        sortCollectionView.backgroundColor = UIColor.clear
        
        let separator = UIView()
        addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.layer.borderWidth = 0.5
        separator.layer.borderColor = AppColors.colorPrimaryText.cgColor
        
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.leadingAnchor.constraint(equalTo: sortLabel.leadingAnchor, constant: -2).isActive = true
        separator.trailingAnchor.constraint(equalTo: sortLabel.trailingAnchor, constant: 2).isActive = true
        separator.topAnchor.constraint(equalTo: sortCollectionView.bottomAnchor,
                                       constant: frame.height * 0.4).isActive = true
        
        sortingOrderSwitch.leadingAnchor.constraint(equalTo: sortLabel.leadingAnchor).isActive = true
        sortingOrderSwitch.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sortingOrderSwitch.topAnchor.constraint(equalTo: separator.bottomAnchor,
                                                constant: frame.height * 0.02).isActive = true
        sortingOrderSwitch.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                   constant: -frame.height * 0.05).isActive = true
    }
    
    
    override func updateData(_ action: SearchRowAction) {
        sortLabel.text = sortAction.label
        sortingOrderSwitch.isOn = sortAction.sortByAscendingOrder
        sortCollectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortAction.sortPositions.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SortTypeCell<T>.identifier, for: indexPath) as Any as? SortTypeCell<T> else {
                fatalError()
        }
        
        let cellPosition = sortAction.sortPositions[indexPath.row]
        cell.sortPosition = cellPosition
        cell.didSelectSortPosition = { [weak self] in self?.didSelectSortPosition($0) }
        
        if let selected = sortAction.selectedSortPosition {
            cell.isSortPositionSelected = cellPosition.label == selected.label
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = sortAction.sortPositions.count <= 3 ?
            UIScreen.main.bounds.deviceWidth / 3.5 : UIScreen.main.bounds.deviceWidth / 3.95
        return CGSize(width: width, height: collectionView.frame.height - 1)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftOffset = sortAction.sortPositions.count <= 3 ?
            UIScreen.main.bounds.deviceWidth * 0.05 : UIScreen.main.bounds.deviceWidth * 0.033
        return UIEdgeInsets(top: 0, left: leftOffset, bottom: 0, right: 0)
    }
    
    
    private func didSelectSortPosition(_ sortPosition: UISearchSortPosition<T>) {
        let previousSelectionIndex = sortAction.selectedSortPositionIndex
        
        sortAction.selectedSortPosition = sortPosition
        sortAction.searchPositionDidUpdate?()
        
        if let _previousSelectionIndex = previousSelectionIndex {
            let indexPath = IndexPath(row: _previousSelectionIndex, section: 0)
            
            if let cell = sortCollectionView.cellForItem(at: indexPath) as Any as? SortTypeCell<T> {
                cell.isSortPositionSelected = false
                sortCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    
    private func setupSwitch() {
        sortingOrderSwitch = LabeledSwitch(offset: frame.height * 0.25)
        sortingOrderSwitch.label.text = "label_title_ascending_order".translated()
        sortingOrderSwitch.label.font = UIFont.myriadPro(size: 17.ifIpad(20))
        sortingOrderSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        sortingOrderSwitch.didChangeValue = { [unowned self] isOn in
            self.sortAction.sortByAscendingOrder = isOn
            self.sortAction.searchPositionDidUpdate?()
        }
    }
}


class SortTypeCell<T>: UICollectionViewCell {
    static var identifier: String { return "SortTypeCell" }
    
    var sortPosition: UISearchSortPosition<T>? {
        didSet {
            sortButton.setImage(sortPosition?.image.tint(with: AppColors.colorPrimary), for: .normal)
            label.text = sortPosition?.label
        }
    }
    
    
    var isSortPositionSelected: Bool = false {
        willSet {
            isUserInteractionEnabled = false
            let bgColor = newValue ? AppColors.colorPrimary.withAlphaComponent(0.2) : UIColor.clear
            
            UIView.animate(withDuration: 0.3, animations: {
                self.sortButton.backgroundColor = bgColor
            }) { _ in
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    
    var didSelectSortPosition: ((UISearchSortPosition<T>) -> ())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    private let sortButton: CorneredButton = {
        let button = CorneredButton(shadow: false)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = AppColors.colorPrimary.cgColor
        button.layer.borderWidth = 2
        button.isUserInteractionEnabled = false
        
        return button
    }()
    
    
    private let label: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.myriadPro(size: 15.ifIpad(18))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    
    private func setupViews() {
        addSubview(sortButton)
        addSubview(label)
        
        sortButton.widthAnchor.constraint(equalToConstant: frame.height * 0.72).isActive = true
        sortButton.heightAnchor.constraint(equalToConstant: frame.height * 0.72).isActive = true
        sortButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        sortButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: sortButton.bottomAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 9).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(positionWasSelected))
        addGestureRecognizer(tap)
    }
    
    
    @objc private func positionWasSelected() {
        if !isSortPositionSelected, let _sortPosition = sortPosition {
            isSortPositionSelected = true
            didSelectSortPosition?(_sortPosition)
        }
    }
}
