
import UIKit


class SOSearchViewManager<T: UpdatableEntity, H: HandlerModel>: SOSearchViewDelegate {
    let handler: TemplateCoreDataHandler<H>
    let searchNavigationDelegate: SearchNavigationDelegate?
    let didSelectObject: (T) -> Void
    
    private(set) var searchView: SOSearchView<T>?
    private let _view: UIView
    private let _searchLabel: String?
    
    
    init(searchLabel: String?, handler: TemplateCoreDataHandler<H>, inside view: UIView,
         navDelegate: SearchNavigationDelegate?, didSelect: @escaping (T) -> Void) {
        self.handler = handler
        self.searchNavigationDelegate = navDelegate
        self.didSelectObject = didSelect
        self._view = view
        self._searchLabel = searchLabel
    }
    
    
    final func showFullscreenSearch() {
        searchView?.removeFromSuperview()
        
        if let searchData = searchData() {
            let searchView = SOSearchView<T>(searchLabel: _searchLabel, search: searchData,
                                             delegate: SOSearchViewDelegateWrapper(self))
            
            _view.addSubview(searchView)
            _view.bringSubviewToFront(searchView)
            
            searchView.topAnchor.constraint(equalTo: _view.topAnchor).isActive = true
            searchView.leadingAnchor.constraint(equalTo: _view.leadingAnchor).isActive = true
            searchView.trailingAnchor.constraint(equalTo: _view.trailingAnchor).isActive = true
            searchView.bottomAnchor.constraint(equalTo: _view.bottomAnchor).isActive = true
            
            self.searchView = searchView
        }
    }
    
    
    open func searchData() -> SOSearchData<T>? {
        return nil
    }
    
    
    func searchDidSelectObject(_ searchView: SOSearchView<T>, _ object: T) {
        didSelectObject(object)
        searchView.close(animated: false)
    }
    
    
    func searchAddButtonData(_ searchView: SOSearchView<T>) -> [OptionButtonData] {
        return []
    }
    
    
    func searchCanCreateObjects(_ searchView: SOSearchView<T>) -> Bool {
        return true
    }
}
