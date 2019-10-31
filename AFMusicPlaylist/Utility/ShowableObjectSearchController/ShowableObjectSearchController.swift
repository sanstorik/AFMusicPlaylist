
import UIKit

protocol ShowableObjectSearchDelegate: class {
    var searchBarTriggerDelay: TimeInterval { get }
    var searchTextDelegate: SearchableTextDelegate? { get set }
    func didStopSearch()
    func searchTextDidChange(_ text: String)
}

protocol SearchableTextDelegate: class {
    var searchText: String? { get }
    var isSearchInFocus: Bool { get set }
    func finishSearch()
}

protocol NavigationBarIconsHandler: class {
    func hideIcons()
    func showIcons()
}

extension NavigationBarIconsHandler where Self: UIViewController {
    func hideIcons() {
        navigationItem.leftBarButtonItems = nil
        navigationItem.rightBarButtonItems = nil
        navigationItem.hidesBackButton = true
    }
}


typealias SearchOutputDataList = UIViewController & ShowableObjectSearchDelegate
typealias SearchPresenter = UIViewController & NavigationBarIconsHandler

final class ShowableObjectSearchController: NSObject, SearchableTextDelegate {
    var searchText: String? {
        return _searchBar.text
    }
    
    var isSearchInFocus: Bool {
        get {
            return _searchBar.isFirstResponder
        }
        set {
            if newValue {
                _searchBar.becomeFirstResponder()
            } else {
                _searchBar.resignFirstResponder()
            }
        }
    }
    
    private var _searchBarLastUpdateTime = Date()
    private var _search: SearchOutputDataList?
    private weak var _presenter: SearchPresenter?
    private let _searchBar = UISearchBar()
    private let _searchListTag = 228
    
    
    init(searchResultsController: SearchOutputDataList?, presenter: SearchPresenter) {
        self._search = searchResultsController
        self._presenter = presenter
        super.init()
        commonInit()
    }
    
    
    func showSearchBar() {
        guard let nSearch = self._search, let nPresenter = self._presenter else {
            return
        }
        
        nPresenter.hideIcons()
        nPresenter.navigationItem.titleView = _searchBar
        _searchBar.setShowsCancelButton(true, animated: false)
        _searchBar.delegate = self
        
        nSearch.view.alpha = 0
        nPresenter.view.addSubview(nSearch.view)
        nSearch.view.tag = _searchListTag
        nSearch.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nSearch.view.leadingAnchor.constraint(equalTo: nPresenter.view.leadingAnchor),
            nSearch.view.trailingAnchor.constraint(equalTo: nPresenter.view.trailingAnchor),
            nSearch.view.topAnchor.constraint(equalTo: nPresenter.view.topSafeAnchorIOS11(nSearch)),
            nSearch.view.bottomAnchor.constraint(equalTo: nPresenter.view.bottomAnchor)
        ])
        
        UIView.animate(withDuration: 0.4) {
            nSearch.view.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self._searchBar.becomeFirstResponder()
        }
    }
    
    
    func finishSearch() {
        _search?.didStopSearch()
        
        _searchBar.text = ""
        _searchBar.setShowsCancelButton(false, animated: false)
        
        _presenter?.navigationItem.titleView = nil
        _presenter?.showIcons()
        
        if let nSearchList = _presenter?.view.viewWithTag(_searchListTag) {
            UIView.animate(withDuration: 0.4, animations: {
                nSearchList.alpha = 0
            }) { _ in
                nSearchList.removeFromSuperview()
            }
        }
    }
    
    
    func updateSearchDataSource(with source: SearchOutputDataList?) -> Bool {
        guard _search?.view.window == nil else {
            return false
        }
        
        self._search = source
        self._search?.searchTextDelegate = self
        
        if #available(iOS 11, *) {
            self._search?.extendedLayoutIncludesOpaqueBars = true
        }
        
        return true
    }
    
    
    private func commonInit() {
        _searchBar.keyboardType = UIKeyboardType.asciiCapable
        _searchBar.searchBarStyle = .minimal
        _searchBar.barStyle = .black
        _searchBar.delegate = self
        _searchBar.sizeToFit()
        _searchBar.keyboardAppearance = .dark
        _search?.searchTextDelegate = self
        
        if #available(iOS 11, *) {
            _presenter?.extendedLayoutIncludesOpaqueBars = true
            _search?.extendedLayoutIncludesOpaqueBars = true
        }
        
        updateUIColors()
    }
    
    
    private func updateUIColors() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder =
            NSAttributedString(
                string: "Search artist", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
    }
}


extension ShowableObjectSearchController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        finishSearch()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text {
            _searchBarLastUpdateTime = Date()
            
            let triggerDelay = min(_search?.searchBarTriggerDelay ?? 0.5, 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + triggerDelay) {
                if Date().timeIntervalSince(self._searchBarLastUpdateTime) > triggerDelay {
                    self._search?.searchTextDidChange(text)
                }
            }
        }
    }
}
