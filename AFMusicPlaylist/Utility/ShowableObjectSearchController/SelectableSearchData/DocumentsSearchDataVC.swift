
import UIKit

final class DocumentSearchDataVC<H: HandlerModel>: RefreshableSortedSearchDataVC<Document> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<H>) {
        let searchHandler = DocumentSearchHandler<H>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: DocumentSearchHandler<H>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createDocumentsSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: DocumentListCell.identifier) { cell, document in
                    if let documentCell = cell as? DocumentListCell {
                        documentCell.updateFrom(document: document)
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(DocumentListCell.self, forCellReuseIdentifier: DocumentListCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createDocumentsSearchSections<H: HandlerModel>(
    searchHandler: DocumentSearchHandler<H>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, Document) -> Void) -> [SearchTemplateSection<Document>] {
    
    let sortAction = SearchSortAction<Document>()
    sortAction.label = "label_title_sorted_by".translated()
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "created_time".translated()) {
            let lhsDeath = $0.created
            let rhsDeath = $1.created
            return lhsDeath?.timeIntervalSince1970 ?? 0 < rhsDeath?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "description".translated()) {
            let lhsName = $0.descriptionValue ?? ""
            let rhsName = $1.descriptionValue ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        },
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "delivered".translated()) {
            let lhs = $0.delivered
            let rhs = $1.delivered
            return lhs?.timeIntervalSince1970 ?? 0 < rhs?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "signed_back".translated()) {
            let lhs = $0.signedBack
            let rhs = $1.signedBack
            return lhs?.timeIntervalSince1970 ?? 0 < rhs?.timeIntervalSince1970 ?? 0
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Document>()
    let dataSection = SearchDataSection<Document>(rowIdentifier: rowIdentifier,
                                                 headerIdentifier: CountSectionHeader.identifier,
                                                 rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: "documents", count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<Document>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class DocumentSearchHandler<H: HandlerModel>: SearchableObjectHandler<Document> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<Document>?
    var handler: TemplateCoreDataHandler<H>!
    
    
    override func isIncluded(_ object: Document, filterByText: String) -> Bool {
        return filterByText.isEmpty
            || object.descriptionValue?.contains(filterByText) ?? false
            || object.documentStatus?.contains(filterByText) ?? false
            || object.fileName?.contains(filterByText) ?? false
    }
    
    
    override func selectedRow(with object: Document) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else { }
    }
    
    
    override func fetchOriginalList() -> [Document] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
