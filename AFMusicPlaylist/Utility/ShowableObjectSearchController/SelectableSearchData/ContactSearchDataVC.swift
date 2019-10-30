

import UIKit


class ContactSearchDataVC<H: HandlerModel>: RefreshableSortedSearchDataVC<SOContact> {
    open var rowCell: TemplateListCell.Type { return ContactListCell.self }
    private let phoneListModel = CallableListCellModel()
    
    
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<H>) {
        let searchHandler = ContactSearchHandler<H>(titleKey: "contacts")
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: ContactSearchHandler<H>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        phoneListModel.presentVC = { [weak self] in self?.present($0, animated: false) }
        
        insertSections(
            createContactsSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: rowCell.identifier) { [unowned self] in
                    self.setupCell($0, contact: $1)
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
    
    
    final func setupCell(_ cell: UITableViewCell, contact: SOContact) {
        if let contactCell = cell as? ContactListCell {
            contactCell.updateFrom(contact: contact, model: phoneListModel)
        }
    }
}


class SelectableContactSearchDataVC<H: HandlerModel>: SelectableSearchDataVC<SOContact> {
    private let phoneListModel = CallableListCellModel()
    
    
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
                     handler: TemplateCoreDataHandler<H>,
                     selectionHandler: SearchSelectedObjectHandler) {
        let searchHandler = ContactSearchHandler<H>(titleKey: "contacts")
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler, selectionHandler: selectionHandler)
    }
    
    
    init(searchHandler: ContactSearchHandler<H>, selectionHandler: SearchSelectedObjectHandler) {
        super.init(searchHandler.searchNavigationDelegate, selectionHandler: selectionHandler)
        phoneListModel.presentVC = { [weak self] in self?.present($0, animated: false) }
        
        let buttonAction = SearchButtonAction()
        buttonAction.label = "label_complete_selection".translated()
        buttonAction.onClick = { [unowned self] in
            self.notifyDidSelect()
            self.searchTextDelegate?.finishSearch()
        }
        
        let doneButtonSection = SearchButtonSection<SOContact>(headerTitle: nil, rowAction: buttonAction)
        var sections = createContactsSearchSections(
            searchHandler: searchHandler,
            rowIdentifier: SelectableContactsCell.identifier) { [unowned self] in
                self.setupCell($0, contact: $1)
        }
        
        sections.insert(doneButtonSection, at: 1)
        insertSections(sections)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(SelectableContactsCell.self, forCellReuseIdentifier: SelectableContactsCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
    
    
    final func setupCell(_ cell: UITableViewCell, contact: SOContact) {
        if let contactCell = cell as? SelectableContactsCell {
            contactCell.updateFrom(contact: contact, model: phoneListModel)
            contactCell.isSelectedForParent = self.isSelected(id: contact.id)
        }
    }
}


fileprivate func createContactsSearchSections<H: HandlerModel>(
    searchHandler: ContactSearchHandler<H>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, SOContact) -> Void) -> [SearchTemplateSection<SOContact>] {
    
    let sortAction = SearchSortAction<SOContact>()
    sortAction.label = "label_title_sorted_by".translated()
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "date".translated()) {
            $0.createdDate?.timeIntervalSince1970 ?? 0 < $1.createdDate?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "A-Z".translated()) {
            let lhsName = $0.company?.briefly ?? $0.person?.surname ?? ""
            let rhsName = $1.company?.briefly ?? $1.person?.surname ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending
        },
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<SOContact>()
    let dataSection = SearchDataSection<SOContact>(
        rowIdentifier: rowIdentifier, headerIdentifier: CountSectionHeader.identifier, rowAction: dataAction
    )
    
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
    
    return [SearchSortSection<SOContact>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class ContactSearchHandler<H: HandlerModel>: SearchableObjectHandler<SOContact> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<SOContact>?
    var handler: TemplateCoreDataHandler<H>!
    let titleKey: String
    
    
    init(titleKey: String) {
        self.titleKey = titleKey
        super.init()
    }
    
    
    override func isIncluded(_ object: SOContact, filterByText: String) -> Bool {
        if let person = object.person {
            return person.first_name?.localizedCaseInsensitiveContains(filterByText) ?? false
                || person.last_name?.localizedCaseInsensitiveContains(filterByText) ?? false
                || person.birth_name?.localizedCaseInsensitiveContains(filterByText) ?? false
        } else if let company = object.company {
            return company.info?.contains(filterByText) ?? false
                || company.briefly?.contains(filterByText) ?? false
                || company.country?.contains(filterByText) ?? false
        }
        
        return false
    }
    
    
    override func selectedRow(with object: SOContact) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            let detailedVC = CompanyDetailedVC<H>()
            detailedVC.handler = handler
            detailedVC.selectedObject = object
            detailedVC.setModificationBlocked(true)
            detailedVC.isSearchPossible = false
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [SOContact] {
        return dataSource?.fetchOriginalList() ?? SOContact.fetchFromDatabase(for: handler, readDeleted: .none)
    }
}
