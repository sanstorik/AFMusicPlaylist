
import UIKit


protocol SearchNavigationDelegate: class {
    func pushViewController(_ vc: UIViewController)
}


class SOSearchData<T>: CommonViewController, UITableViewDelegate, UITableViewDataSource,
UIGestureRecognizerDelegate, ShowableObjectSearchDelegate {
    var searchBarTriggerDelay: TimeInterval { return 0.6 }
    weak var searchTextDelegate: SearchableTextDelegate?
    
    private(set) lazy var searchTableView = createSearchTableView()
    private(set) var sections = [SearchTemplateSection<T>]()
    private weak var searchNavigationDelegate: SearchNavigationDelegate?

    
    init(searchNavigationDelegate: SearchNavigationDelegate?) {
        self.searchNavigationDelegate = searchNavigationDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAllDataSection(filterText: searchTextDelegate?.searchText)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBackground(AFColors.background)
    }
    
    
    private func setupViews() {
        view.addSubview(searchTableView)
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        registerCustomDataCells(searchTableView)
        let tapGesture = registerDismissingKeyboardOnTap()
        tapGesture.delegate = self
        
        if #available(iOS 11, *) {
            searchTableView.contentInsetAdjustmentBehavior = .never
            searchTableView.contentInset.bottom = view.safeAreaInsets.bottom
        }
    }
    
    
    private func createSearchTableView() -> UITableView {
        let table = UITableView(frame: CGRect.zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor.clear
        table.estimatedRowHeight = 0
        table.estimatedSectionFooterHeight = 0
        table.estimatedSectionHeaderHeight = 0
        table.separatorStyle = .singleLine
        table.separatorColor = .lightGray
        return table
    }
    
    
    // #MARK: Search Text field delegate
    override func dismissKeyboard() {
        searchTextDelegate?.isSearchInFocus = false
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return searchTextDelegate?.isSearchInFocus ?? false
    }
    
    
    func didStopSearch() { }
    
    
    func searchTextDidChange(_ text: String) {
        updateAllDataSection(filterText: text)
    }
    
    
    // #MARK: Table data source and delegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let _section = sections[section]
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: _section.headerIdentifier),
            _section.useHeader else {
                return nil
        }
        
        if let dataRowAction = _section.rowAction as? SearchDataRowAction<T>,
            let dataSection = sectionToSearchDataSection(_section) {
            dataRowAction.setupHeaderCallback?(header, dataSection.resultingList)
            return header
        }
        

        fatalError()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowsCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: section.rowIdentifier, for: indexPath)
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = AFColors.highlightColor
        
        if let dataRowAction = section.rowAction as? SearchDataRowAction<T>,
            let dataSection = sectionToSearchDataSection(section) {
            /* Pagination */
            if dataSection.isReadyToPerformPagination(displaying: indexPath.row) {
                dataSection.performPagination(searchTextDelegate?.searchText) { fetchedIndecies in
                    let rows = fetchedIndecies.map { IndexPath(row: $0, section: indexPath.section) }
                    self.searchTableView.insertRows(at: rows, with: .none)
                }
            }
            
            dataRowAction.setupCellCallback!(cell, dataSection.resultingList[indexPath.row])
            return cell
        }
        
        guard let searchCell = cell as Any as? ShowableObjectSearchCell<T> else {
            fatalError()
        }
        
        
        if let searchRowAction = section.rowAction as? UpdatableSearchRowAction {
            searchRowAction.searchPositionDidUpdate = { [weak self] in
                if searchRowAction is SearchSortAction<T> {
                    self?.sortObjectsSync(filterText: self?.searchTextDelegate?.searchText)
                } else {
                    self?.updateAllDataSection(filterText: self?.searchTextDelegate?.searchText)
                }
            }
        }
        
        searchCell.rowAction = section.rowAction
        return searchCell
    }
    
    
    // #MARK: Searchable list data
    
    open func registerCustomDataCells(_ tableView: UITableView) { }
    
    
    final func insertSections(_ sections: [SearchTemplateSection<T>]) {
        self.sections += sections
    }
    
    
    // #MARK: Updating search data section with updated sorting and filter positions
    
    final func updateAllDataSection(filterText: String?) {
        let filterCollector = collectSearchPositions()
        
        for i in 0..<sections.count {
            if let dataSection = sectionToSearchDataSection(sections[i]) {
                self.view.showLoader()
                dataSection.filterByStringAsync(filterText, filterCollector: filterCollector) {
                    self.view.removeLoader()
                    self.searchTableView.reloadSections(IndexSet(arrayLiteral: i), with: .fade)
                }
            }
        }
    }
    
    
    final func sortObjectsSync(filterText: String?) {
        let filterCollector = collectSearchPositions()
        var sectionsToReload = IndexSet()
        
        for i in 0..<sections.count {
            if let dataSection = sectionToSearchDataSection(sections[i]) {
                dataSection.sortObjects(filterText, filterCollector: filterCollector)
                sectionsToReload.insert(i)
            }
        }
        
        self.searchTableView.reloadSections(sectionsToReload, with: .fade)
    }
    
    
    private func sectionToSearchDataSection(_ section: SearchTemplateSection<T>) -> SearchDataSection<T>? {
        return section as Any as? SearchDataSection
    }
    
    
    private func collectSearchPositions() -> SearchFilterCollector<T> {
        var sortAscending = true
        var sortingPositions = [UISearchSortPosition<T>]()
        let filteringPositions = [SearchFilterPosition<T>]()
        
        for section in sections {
            if let sortAction = section.rowAction as? SearchSortAction<T>,
                let selected = sortAction.selectedSortPosition {
                sortingPositions.append(selected)
                sortAscending = sortAction.sortByAscendingOrder
            }
        }
        
        
        return SearchFilterCollector<T>(sortingPositions: sortingPositions,
                                        filteringPositions: filteringPositions,
                                        sortAscending: sortAscending)
    }
    
    // #MARK: Table view sizes
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].rowHeightFor(frame: UIScreen.main.bounds)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].useHeader ? tableView.frame.deviceHeight * 0.05 : CGFloat.leastNonzeroMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.frame.deviceHeight * 0.035
    }
    
    
    // #MARK: Cell callbacks
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as Any as? ShowableObjectSearchCell<T> {
            cell.didUnhiglight()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        if let dataSection = sectionToSearchDataSection(section) {
            dataSection.selectedRow(at: indexPath.row)
        } else if let cell = tableView.cellForRow(at: indexPath) as Any as? ShowableObjectSearchCell<T> {
            cell.didSelect()
        }
    }
}
