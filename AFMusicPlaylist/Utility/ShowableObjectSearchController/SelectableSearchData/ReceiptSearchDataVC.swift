
import UIKit

final class ReceiptSearchDataVC<H: HandlerModel>: RefreshableSortedSearchDataVC<Receipt> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<H>) {
        let searchHandler = ReceiptSearchHandler<H>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: ReceiptSearchHandler<H>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createReceiptsSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: ReceiptListCell.identifier) { cell, receipt in
                    if let receiptCell = cell as? ReceiptListCell {
                        receiptCell.updateFrom(receipt: receipt)
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(ReceiptListCell.self, forCellReuseIdentifier: ReceiptListCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createReceiptsSearchSections<H: HandlerModel>(
    searchHandler: ReceiptSearchHandler<H>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, Receipt) -> Void) -> [SearchTemplateSection<Receipt>] {
    
    let sortAction = SearchSortAction<Receipt>()
    sortAction.label = "label_title_sorted_by".translated()
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "created_time".translated()) {
            let lhsDeath = $0.created
            let rhsDeath = $1.created
            return lhsDeath?.timeIntervalSince1970 ?? 0 < rhsDeath?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "total_price".translated()) {
            let lhsName = $0.total
            let rhsName = $1.total
            return lhsName < rhsName
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "receipt_status".translated()) {
            let lhsName = $0.receipt_status ?? ""
            let rhsName = $1.receipt_status ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Receipt>()
    let dataSection = SearchDataSection<Receipt>(rowIdentifier: rowIdentifier,
                                                headerIdentifier: CountSectionHeader.identifier,
                                                rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: "tab_title_receipts", count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<Receipt>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class ReceiptSearchHandler<H: HandlerModel>: SearchableObjectHandler<Receipt> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<Receipt>?
    var handler: TemplateCoreDataHandler<H>!
    
    
    override func isIncluded(_ object: Receipt, filterByText: String) -> Bool {
        return filterByText.isEmpty
            || object.receipt_nr?.contains(filterByText) ?? false
            || object.customers_nr?.contains(filterByText) ?? false
            || object.customers_reference?.contains(filterByText) ?? false
            || object.receipt_status?.contains(filterByText) ?? false
    }
    
    
    override func selectedRow(with object: Receipt) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            handler.setupBeforeEditing(object)
            
            let detailedVC = OrderReceiptDetailedVC()
            detailedVC.selectedObject = object
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [Receipt] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
