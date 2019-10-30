
import UIKit


final class ItemSearchDataVC<T: HandlerModel>: RefreshableSortedSearchDataVC<Item> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
         handler: TemplateCoreDataHandler<T>) {
        
        let searchHandler = ItemSearchHandler<T>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: ItemSearchHandler<T>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createItemsSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: ItemsListCell.identifier) { cell, item in
                    if let itemCell = cell as? ItemsListCell {
                        itemCell.updateFrom(item: item)
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(ItemsListCell.self, forCellReuseIdentifier: ItemsListCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


protocol ItemCountableSearchDataDelegate: class {
    func selectedItems() -> [Int64: Int64]
    func onSelectedItemsUpdated(_ selectedItems: [Int64: Int64])
    func maxSelectionAmountFor(item: Item) -> Int64
    func hasUpdatePermissions() -> Bool
}


final class SelectableItemSearchDataVC<T: HandlerModel>: SelectableSearchDataVC<Item>, SelectableItemDataSource {
    private weak var countableDelegate: ItemCountableSearchDataDelegate?
    var selectedItemsCount = [Int64: Int64]()
    
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
         handler: TemplateCoreDataHandler<T>,
         selectionHandler: SearchSelectedObjectHandler,
         countableDelegate: ItemCountableSearchDataDelegate) {
        let searchHandler = ItemSearchHandler<T>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler, selectionHandler: selectionHandler,
                  countableDelegate: countableDelegate)
    }
    
    
    init(searchHandler: ItemSearchHandler<T>,
         selectionHandler: SearchSelectedObjectHandler,
         countableDelegate: ItemCountableSearchDataDelegate) {
        self.countableDelegate = countableDelegate
        super.init(searchHandler.searchNavigationDelegate, selectionHandler: selectionHandler)
        
        let buttonAction = SearchButtonAction()
        buttonAction.label = "label_complete_selection".translated()
        buttonAction.onClick = { [unowned self] in
            self.notifyDidSelect()
            self.countableDelegate?.onSelectedItemsUpdated(self.selectedItemsCount)
            self.searchTextDelegate?.finishSearch()
        }
        
        let doneButtonSection = SearchButtonSection<Item>(headerTitle: nil, rowAction: buttonAction)
        var sections = createItemsSearchSections(searchHandler: searchHandler,
                                                 rowIdentifier: SelectableItemsCell.identifier)
        { cell, item in
            guard let itemCell = cell as? SelectableItemsCell else { return }
            itemCell.isPriceCategoryPickerNeeded = false
            itemCell.setupSelectableCell(from: item, dataSource: self)
        }
        
        sections.insert(doneButtonSection, at: 1)
        insertSections(sections)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedItemsCount = countableDelegate?.selectedItems() ?? [:]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(SelectableItemsCell.self, forCellReuseIdentifier: SelectableItemsCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
    
    
    func maxSelectionAmountFor(item: Item) -> Int64 {
        return self.countableDelegate?.maxSelectionAmountFor(item: item) ?? Int64.max
    }
    
    
    func shouldCountButtonsBeActive(for item: Item) -> Bool {
        return countableDelegate?.hasUpdatePermissions() ?? true
    }
}


fileprivate func createItemsSearchSections<T: HandlerModel>(
    searchHandler: ItemSearchHandler<T>, rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, Item) -> Void) -> [SearchTemplateSection<Item>] {
    
    let sortAction = SearchSortAction<Item>()
    sortAction.label = "label_title_sorted_by".translated()
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "date".translated()) {
            $0.created?.timeIntervalSince1970 ?? 0 < $1.created?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "short_text".translated()) {
            let lhsName = $0.shortText ?? ""
            let rhsName = $1.shortText ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        },
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "delivery_time".translated()) {
            let lhs = $0.deliveryTime
            let rhs = $1.deliveryTime
            return lhs?.timeIntervalSince1970 ?? 0 < rhs?.timeIntervalSince1970 ?? 0
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Item>()
    let dataSection = SearchDataSection<Item>(rowIdentifier: rowIdentifier,
                                                      headerIdentifier: CountSectionHeader.identifier,
                                                      rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: "items", count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<Item>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class ItemSearchHandler<T: HandlerModel>: SearchableObjectHandler<Item> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<Item>?
    var handler: TemplateCoreDataHandler<T>!
    
    override func isIncluded(_ object: Item, filterByText: String) -> Bool {
        return filterByText.isEmpty
            || object.shortText?.contains(filterByText) ?? false
            || object.longText?.contains(filterByText) ?? false
            || object.advertisingText?.contains(filterByText) ?? false
            || object.itemNr?.contains(filterByText) ?? false
    }
    
    
    override func selectedRow(with object: Item) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            CoreDataHandler.shared.itemHandler.setupBeforeEditing(object)
            
            let detailedVC = ItemDetailVC()
            detailedVC.selectedObject = object
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [Item] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
