
import UIKit

final class TodoTemplateSearchDataVC<T: HandlerModel>: RefreshableSortedSearchDataVC<TodoTemplate> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
         handler: TemplateCoreDataHandler<T>) {
        let searchHandler = TodoTemplateSearchHandler<T>()
        searchHandler.handler = handler
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: TodoTemplateSearchHandler<T>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)

        insertSections(
            createTodoTemplatesSearchSections(searchHandler: searchHandler,
                                              rowIdentifier: TodoListCell.identifier) { cell, todoTemplate in
                                                if let todoTemplateCell = cell as? TodoListCell {
                                                    todoTemplateCell.updateFrom(template: todoTemplate)
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


final class SelectableTodoTemplateSearchDataVC<T: HandlerModel>: SelectableSearchDataVC<TodoTemplate> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
         handler: TemplateCoreDataHandler<T>,
         selectionHandler: SearchSelectedObjectHandler) {
        let searchHandler = TodoTemplateSearchHandler<T>()
        searchHandler.handler = handler
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        
        self.init(searchHandler: searchHandler, selectionHandler: selectionHandler)
    }
    
    
    init(searchHandler: TodoTemplateSearchHandler<T>, selectionHandler: SearchSelectedObjectHandler) {
        super.init(searchHandler.searchNavigationDelegate, selectionHandler: selectionHandler)
        
        let buttonAction = SearchButtonAction()
        buttonAction.label = "label_complete_selection".translated()
        buttonAction.onClick = { [unowned self] in
            self.notifyDidSelect()
            self.searchTextDelegate?.finishSearch()
        }
        
        let doneButtonSection = SearchButtonSection<TodoTemplate>(headerTitle: nil, rowAction: buttonAction)
        var sections = createTodoTemplatesSearchSections(searchHandler: searchHandler,
            rowIdentifier: SelectableTodoCell.identifier) { [unowned self] cell, todoTemplate in
                if let todoTemplateCell = cell as? SelectableTodoCell {
                    todoTemplateCell.updateFrom(template: todoTemplate)
                    todoTemplateCell.isSelectedForParent = self.isSelected(id: todoTemplate.id)
                }
        }
        
        sections.insert(doneButtonSection, at: 1)
        insertSections(sections)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(SelectableTodoCell.self, forCellReuseIdentifier: SelectableTodoCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createTodoTemplatesSearchSections<T: HandlerModel>(
    searchHandler: TodoTemplateSearchHandler<T>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, TodoTemplate) -> Void) -> [SearchTemplateSection<TodoTemplate>] {
    
    let sortAction = SearchSortAction<TodoTemplate>()
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
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "prior_time".translated()) {
            let lhsDeath = $0.priorTime
            let rhsDeath = $1.priorTime
            return lhsDeath?.timeIntervalSince1970 ?? 0 < rhsDeath?.timeIntervalSince1970 ?? 0
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<TodoTemplate>()
    let dataSection = SearchDataSection<TodoTemplate>(rowIdentifier: rowIdentifier,
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
    
    return [SearchSortSection<TodoTemplate>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class TodoTemplateSearchHandler<T: HandlerModel>: SearchableObjectHandler<TodoTemplate> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<TodoTemplate>?
    var handler: TemplateCoreDataHandler<T>!
    
    override func isIncluded(_ object: TodoTemplate, filterByText: String) -> Bool {
        return filterByText.isEmpty
            || object.shortText?.contains(filterByText) ?? false
            || object.longText?.contains(filterByText) ?? false
            || object.statementText?.contains(filterByText) ?? false
    }
    
    
    override func selectedRow(with object: TodoTemplate) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            handler.setupBeforeEditing(object)
            
            let detailedVC = TodoTemplateDetailVC()
            detailedVC.selectedObject = object
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [TodoTemplate] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
