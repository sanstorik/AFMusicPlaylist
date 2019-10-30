
import UIKit


class OrderSearchDataVC: RefreshableSortedSearchDataVC<Order> {
    private let orderCellViewModel = OrderCellViewModel()
    
    
    convenience init(navigationDelegate: SearchNavigationDelegate?) {
        let searchHandler = OrderSearchHandler()
        searchHandler.searchNavigationDelegate = navigationDelegate
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: OrderSearchHandler) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createOrdersSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: DefaultListCell.identifier) { cell, order in
                    if let orderCell = cell as? DefaultListCell {
                        let cellModel = self.orderCellViewModel.cellModelFor(order: order)
                        orderCell.top = cellModel.top
                        orderCell.middle = cellModel.mid
                        orderCell.bottom = cellModel.bottom
                        orderCell.statusIcon = cellModel.statusIcon
                        orderCell.onPinClicked = cellModel.onPinClicked
                        orderCell.isPinned = cellModel.isPinned
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(DefaultListCell.self, forCellReuseIdentifier: DefaultListCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createOrdersSearchSections(
    searchHandler: OrderSearchHandler,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, Order) -> Void) -> [SearchTemplateSection<Order>] {
    
    let sortAction = SearchSortAction<Order>()
    sortAction.label = "label_title_sorted_by".translated()
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "date".translated()) {
            $0.created?.timeIntervalSince1970 ?? 0 < $1.created?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "decedent_forename".translated()) {
            let lhsName = $0.decedent?.person?.first_name ?? ""
            let rhsName = $1.decedent?.person?.first_name ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        },
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "decedent_deathdate".translated()) {
            let lhsDeath = $0.decedent?.deathDateTime
            let rhsDeath = $1.decedent?.deathDateTime
            return lhsDeath?.timeIntervalSince1970 ?? 0 < rhsDeath?.timeIntervalSince1970 ?? 0
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Order>()
    let dataSection = SearchDataSection<Order>(rowIdentifier: rowIdentifier,
                                               headerIdentifier: CountSectionHeader.identifier,
                                               rowAction: dataAction)
    dataAction.setupCellCallback = setupCellCallback
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: "orders", count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    dataSection.searchableObjectDelegate = searchHandler
    return [SearchSortSection<Order>(headerTitle: "", rowAction: sortAction), dataSection]
}


final class OrderSearchHandler: SearchableObjectHandler<Order> {
    var dataSource: SearchDataSourceWrapper<Order>?
    weak var searchNavigationDelegate: SearchNavigationDelegate?

    
    override func isIncluded(_ object: Order, filterByText: String) -> Bool {
        let orderNumber = object.orderNumber?.contains(filterByText) ?? false
        let decedentName = object.decedent?.person?.first_name?.starts(with: filterByText) ?? false
        
        return orderNumber || decedentName
    }
    
    
    override func selectedRow(with object: Order) {
        CoreDataHandler.shared.orderHandler.setupBeforeEditing(object)
        object.setupMandatoryValues()
        
        let detailedVC = DetailedOrderViewController()
        detailedVC.selectedObject = (object, false)
        
        searchNavigationDelegate?.pushViewController(detailedVC)
    }
    
    
    override func fetchOriginalList() -> [Order] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.orderHandler.fetchInChildContext().filter { !$0.isDeletedValue }
    }
}
