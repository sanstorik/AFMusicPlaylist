
import UIKit

final class TodoSearchDataVC<T: HandlerModel>: RefreshableSortedSearchDataVC<Todo> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<T>) {
        let searchHandler = TodoSearchHandler<T>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: TodoSearchHandler<T>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createTodosSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: TodoListCell.identifier) { cell, todo in
                    if let todoCell = cell as? TodoListCell {
                        todoCell.updateFrom(todo: todo)
                        
                        if let orderNumber = todo.order?.orderNumber {
                            todoCell.top = "\("order_number".translated()): \(orderNumber)"
                        } else {
                            todoCell.top = "message_no_assigned_order".translated()
                        }
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createTodosSearchSections<T: HandlerModel>(
    searchHandler: TodoSearchHandler<T>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, Todo) -> Void) -> [SearchTemplateSection<Todo>] {
    
    let sortAction = SearchSortAction<Todo>()
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
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "end_date".translated()) {
            let lhsDeath = $0.until_datatime
            let rhsDeath = $1.until_datatime
            return lhsDeath?.timeIntervalSince1970 ?? 0 < rhsDeath?.timeIntervalSince1970 ?? 0
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Todo>()
    let dataSection = SearchDataSection<Todo>(rowIdentifier: rowIdentifier,
                                                headerIdentifier: CountSectionHeader.identifier,
                                                rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: "todos_tab_title", count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<Todo>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class TodoSearchHandler<T: HandlerModel>: SearchableObjectHandler<Todo> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<Todo>?
    var handler: TemplateCoreDataHandler<T>!
    
    override func isIncluded(_ object: Todo, filterByText: String) -> Bool {
        let doesOrderNumberFit = object.order?.orderNumber?.contains(filterByText) ?? false
        return filterByText.isEmpty
            || object.shortText?.contains(filterByText) ?? false
            || object.longText?.contains(filterByText) ?? false
            || doesOrderNumberFit
    }
    
    
    override func selectedRow(with object: Todo) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            CoreDataHandler.shared.todoHandler.setupBeforeEditing(object)
            
            let detailedVC = TodoDetailVC()
            detailedVC.selectedObject = object
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [Todo] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
