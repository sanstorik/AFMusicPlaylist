

import UIKit


class RefreshableSortedSearchDataVC<T>: SOSearchData<T>, PullToRefresh, SyncableVC {
    override init(searchNavigationDelegate: SearchNavigationDelegate?) {
        super.init(searchNavigationDelegate: searchNavigationDelegate)
        setupUpdateSyncObserver(selector: #selector(onSyncEventRaised))
        setupPullToRefresh()
    }
    
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    
    deinit {
        deinitUpdateSyncObverver()
    }
    
    
    override func viewDidLoad() {
        setupBackground()
        super.viewDidLoad()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        tableView.register(SortCell<T>.self, forCellReuseIdentifier: SortCell<T>.identifier)
        tableView.register(LabelCellHeader.self, forHeaderFooterViewReuseIdentifier: LabelCellHeader.identifier)
        tableView.register(ButtonCell<T>.self, forCellReuseIdentifier: ButtonCell<T>.identifier)
    }
    
    
    // #MARK: Pull to refresh for updating searching list
    
    var pullToRefresh: UIRefreshControl!
    
    func setupPullToRefresh() {
        pullToRefresh = UIRefreshControl()
        pullToRefresh.addTarget(self, action: #selector(refresh), for: .valueChanged)
        searchTableView.addSubview(pullToRefresh)
    }
    
    
    @objc private func refresh() {
        pullToRefreshStartSync()
    }
    
    
    @objc private func onSyncEventRaised() {
        DispatchQueue.main.async { [weak self] in
            if self?.view.window != nil {
                self?.updateAllDataSection(filterText: self?.searchTextDelegate?.searchText, updateOriginalList: true)
            }
        }
    }
}
