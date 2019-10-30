

import UIKit


class SOSearchView<T>: UIView {
    private let addButtonInset: CGFloat = 40
    
    private lazy var _searchTextField = LabelTextField(inside: frame, offsetY: 10, alwaysShowTitle: true)
    private lazy var _spawner = SOViewSpawnDecorator(view: self)
    private var _addButton: UIView?
    private var _cancelButtomBottomConstraint: NSLayoutConstraint?
    private let _cancelButton = UIButton()
    private let _searchLabel: String?
    private let _delegate: SOSearchViewDelegateWrapper<T>
    private let _searchList: SOSearchData<T>
    
    
    init(searchLabel: String?, search: SOSearchData<T>, delegate: SOSearchViewDelegateWrapper<T>) {
        self._searchLabel = searchLabel
        self._searchList = search
        self._delegate = delegate
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        setupKeyboardObservers()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    

    override func didMoveToSuperview() {
        if superview != nil {
            open()
        }
    }
    
    
    @objc private func didChangeText(_ textField: UITextField) {
        _searchList.searchTextDidChange(textField.text ?? "")
    }
    
    
    @objc private func didSelectCancel() {
        finishSearch()
    }
    
    
    @objc private func didSelectAddButton() {
        if let data = _delegate.searchAddButtonData(self).first {
            data.action()
        }
    }
    
    
    @objc private func willShowKeyboard(_ notification: NSNotification) {
        _cancelButtomBottomConstraint?.constant = -notification.endFrameKeyboardSize.height - addButtonInset / 2
        updateLayoutAnimated()
    }
    
    
    @objc private func willHideKeyboard(_ notification: NSNotification) {
        _cancelButtomBottomConstraint?.constant = -addButtonInset
        updateLayoutAnimated()
    }
    
    
    private func updateLayoutAnimated(duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
}


extension SOSearchView: SearchableTextDelegate {
    var searchText: String? {
        return _searchTextField.text
    }
    
    
    var isSearchInFocus: Bool {
        get {
            return _searchTextField.isFirstResponder
        }
        set {
            if newValue {
                _searchTextField.becomeFirstResponder()
            } else {
                _searchTextField.resignFirstResponder()
            }
        }
    }
    
    
    func finishSearch() {
        close()
    }
}


extension SOSearchView {
    func open(animated: Bool = true) {
        if animated {
            isUserInteractionEnabled = false
            alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
            }) { _ in
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    
    func close(animated: Bool = true) {
        if animated {
            isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
    
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    private func setupViews() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        _searchTextField.font = UIFont.myriadPro(size: 17.ifIpad(19))
        _searchTextField.placeholderFont = UIFont.myriad(size: 17.ifIpad(19))
        _searchTextField.titleFont = UIFont.myriad(size: 16.ifIpad(17))
        _searchTextField.translatesAutoresizingMaskIntoConstraints = false
        _searchTextField.title = _searchLabel
        
        _searchTextField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        addSubview(_searchTextField)
        
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false
        _cancelButton.setTitle("cancel".translated(), for: .normal)
        _cancelButton.setTitleColor(AppColors.colorPrimary, for: .normal)
        _cancelButton.fontSize = 16.ifIpad(19)
        _cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        _cancelButton.addTarget(self, action: #selector(didSelectCancel), for: .touchUpInside)
        addSubview(_cancelButton)
        
        _searchList.searchTextDelegate = self
        _searchList.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(_searchList.view)
        
        let buttonsData = _delegate.searchAddButtonData(self)
        if buttonsData.count > 1 {
            setupMultiOptionAddButton(data: buttonsData)
        } else {
            setupSingleChoiceAddButton()
        }
        
        _addButton?.isHidden = !_delegate.searchCanCreateObjects(self) || buttonsData.count == 0
    }
    
    
    private func setupConstraints() {
        let separator = UIView()
        separator.backgroundColor = UIColor.gray
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.alpha = 0.4
        addSubview(separator)
        
        let constraints = [
            _searchTextField.leadingAnchor.constraint(equalTo: leadingA, constant: 25),
            _searchTextField.trailingAnchor.constraint(equalTo: _cancelButton.leadingAnchor, constant: -10),
            _searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            _searchTextField.heightAnchor.constraint(equalToConstant: 60),
            
            _cancelButton.heightAnchor.constraint(equalTo: _searchTextField.heightAnchor),
            _cancelButton.trailingAnchor.constraint(equalTo: trailingA, constant: -10),
            _cancelButton.centerYAnchor.constraint(equalTo: _searchTextField.centerYAnchor),
            _cancelButton.widthAnchor.constraint(equalToConstant: 100),
            
            separator.leadingAnchor.constraint(equalTo: leadingA, constant: 21),
            separator.trailingAnchor.constraint(equalTo: _cancelButton.leadingAnchor, constant: -6),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.topAnchor.constraint(equalTo: _searchTextField.bottomAnchor, constant: -2),
            
            _searchList.view.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 10),
            _searchList.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            _searchList.view.leadingAnchor.constraint(equalTo: leadingA),
            _searchList.view.trailingAnchor.constraint(equalTo: trailingA)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    private func setupMultiOptionAddButton(data: [OptionButtonData]) {
        let buttonHolder = SOFABMenu(data: data)
        buttonHolder.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonHolder)
        self._addButton = buttonHolder
        self._cancelButtomBottomConstraint = buttonHolder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        self._cancelButtomBottomConstraint?.isActive = true
        
        buttonHolder.trailingAnchor.constraint(equalTo: trailingA, constant: -20).isActive = true
        buttonHolder.widthAnchor.constraint(equalToConstant: 60).isActive = true
        buttonHolder.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    
    private func setupSingleChoiceAddButton(){
        let button = CorneredButton(shadow: false)
        button.setImage(UIImage(named: "ic_add_white_48pt"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = AppColors.colorPrimary
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        addSubview(button)
        self._addButton = button
        self._cancelButtomBottomConstraint = button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        self._cancelButtomBottomConstraint?.isActive = true
        
        button.addTarget(self, action: #selector(didSelectAddButton), for: .touchUpInside)
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}


protocol SOSearchViewDelegate {
    associatedtype SearchableObject
    func searchDidSelectObject(_ searchView: SOSearchView<SearchableObject>, _ object: SearchableObject)
    func searchAddButtonData(_ searchView: SOSearchView<SearchableObject>) -> [OptionButtonData]
    func searchCanCreateObjects(_ searchView: SOSearchView<SearchableObject>) -> Bool
}


struct SOSearchViewDelegateWrapper<T>: SOSearchViewDelegate {
    private let _searchDidSelectObject: (SOSearchView<T>, T) -> Void
    private let _searchAddButtonData: (SOSearchView<T>) -> [OptionButtonData]
    private let _searchCanCreateObjects: (SOSearchView<T>) -> Bool
    
    
    init<S>(_ delegate: S) where S: SOSearchViewDelegate, S.SearchableObject == T {
        self._searchDidSelectObject = delegate.searchDidSelectObject
        self._searchAddButtonData = delegate.searchAddButtonData
        self._searchCanCreateObjects = delegate.searchCanCreateObjects
    }
    
    
    func searchDidSelectObject(_ searchView: SOSearchView<T>, _ object: T) {
        _searchDidSelectObject(searchView, object)
    }
    
    
    func searchAddButtonData(_ searchView: SOSearchView<T>) -> [OptionButtonData] {
        return _searchAddButtonData(searchView)
    }
    
    
    func searchCanCreateObjects(_ searchView: SOSearchView<T>) -> Bool {
        return _searchCanCreateObjects(searchView)
    }
}
