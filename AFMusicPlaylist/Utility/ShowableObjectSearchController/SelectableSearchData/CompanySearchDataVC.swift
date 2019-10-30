

import UIKit


class CompanySearchDataVC<H: HandlerModel>: RefreshableSortedSearchDataVC<Company> {
    open var rowCell: TemplateListCell.Type { return CompanyListCell.self }
    
    
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<H>) {
        let searchHandler = CompanySearchHandler<H>(titleKey: "contacts")
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: CompanySearchHandler<H>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createCompaniesSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: rowCell.identifier) { [unowned self] in
                    self.setupCell($0, company: $1)
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(rowCell.self, forCellReuseIdentifier: rowCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
    
    
    open func setupCell(_ cell: UITableViewCell, company: Company) {
        if let companyCell = cell as? CompanyListCell {
            companyCell.updateFrom(company: company)
        }
    }
}



class SelectableCompanySearchDataVC<H: HandlerModel>: SelectableSearchDataVC<Company> {
    private let phoneListModel = CallableListCellModel()
    
    
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
                     handler: TemplateCoreDataHandler<H>,
                     selectionHandler: SearchSelectedObjectHandler) {
        let searchHandler = CompanySearchHandler<H>(titleKey: "contacts")
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler, selectionHandler: selectionHandler)
    }
    
    
    init(searchHandler: CompanySearchHandler<H>, selectionHandler: SearchSelectedObjectHandler) {
        super.init(searchHandler.searchNavigationDelegate, selectionHandler: selectionHandler)
        
        let buttonAction = SearchButtonAction()
        buttonAction.label = "label_complete_selection".translated()
        buttonAction.onClick = { [unowned self] in
            self.notifyDidSelect()
            self.searchTextDelegate?.finishSearch()
        }
        
        let doneButtonSection = SearchButtonSection<Company>(headerTitle: nil, rowAction: buttonAction)
        var sections = createCompaniesSearchSections(
            searchHandler: searchHandler,
            rowIdentifier: SelectableCompanyCell.identifier) { [unowned self]in
                self.setupCell($0, company: $1)
        }
        
        sections.insert(doneButtonSection, at: 1)
        insertSections(sections)
        
        phoneListModel.presentVC = { [weak self] in self?.present($0, animated: false) }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(SelectableCompanyCell.self, forCellReuseIdentifier: SelectableCompanyCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
    
    
    open func setupCell(_ cell: UITableViewCell, company: Company) {
        if let companyCell = cell as? SelectableCompanyCell {
            companyCell.updateFrom(company: company, model: phoneListModel)
            companyCell.isSelectedForParent = self.isSelected(id: company.id)
        }
    }
}


fileprivate func createCompaniesSearchSections<H: HandlerModel>(
    searchHandler: CompanySearchHandler<H>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, Company) -> Void) -> [SearchTemplateSection<Company>] {
    
    let sortAction = SearchSortAction<Company>()
    sortAction.label = "label_title_sorted_by".translated()
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "date".translated()) {
            $0.created?.timeIntervalSince1970 ?? 0 < $1.created?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "short_text".translated()) {
            let lhsName = $0.briefly ?? ""
            let rhsName = $1.briefly ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "country".translated()) {
            let lhsName = $0.country ?? ""
            let rhsName = $1.country ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Company>()
    let dataSection = SearchDataSection<Company>(rowIdentifier: rowIdentifier,
                                                headerIdentifier: CountSectionHeader.identifier,
                                                rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: searchHandler.titleKey, count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<Company>(headerTitle: "", rowAction: sortAction),
            dataSection]
}



final class CompanySearchHandler<H: HandlerModel>: SearchableObjectHandler<Company> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<Company>?
    var handler: TemplateCoreDataHandler<H>!
    let titleKey: String
    
    init(titleKey: String) {
        self.titleKey = titleKey
        super.init()
    }

    
    override func isIncluded(_ object: Company, filterByText: String) -> Bool {
        return filterByText.isEmpty
            || object.info?.contains(filterByText) ?? false
            || object.briefly?.contains(filterByText) ?? false
            || object.country?.contains(filterByText) ?? false
    }
    
    
    override func selectedRow(with object: Company) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            handler.setupBeforeEditing(object)
            
            let detailedVC = CompanyDetailedVC<H>()
            detailedVC.handler = handler
            detailedVC.selectedObject = object
            detailedVC.setModificationBlocked(true)
            detailedVC.isSearchPossible = false
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [Company] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
