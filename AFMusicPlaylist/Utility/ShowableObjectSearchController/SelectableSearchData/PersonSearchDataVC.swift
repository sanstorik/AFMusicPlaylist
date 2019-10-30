
import UIKit

final class PersonSearchDataVC<H: HandlerModel>: RefreshableSortedSearchDataVC<Person> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<H>) {
        let searchHandler = PersonSearchHandler<H>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: PersonSearchHandler<H>, titleKey: String = "persons") {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createPersonsSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: PersonListCell.identifier,
                titleKey: titleKey) { cell, person in
                    if let personCell = cell as? PersonListCell {
                        personCell.updateFrom(person: person)
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(PersonListCell.self, forCellReuseIdentifier: PersonListCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


final class SelectablePersonSearchDataVC<H: HandlerModel>: SelectableSearchDataVC<Person> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
                     handler: TemplateCoreDataHandler<H>,
                     selectionHandler: SearchSelectedObjectHandler) {
        let searchHandler = PersonSearchHandler<H>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler, selectionHandler: selectionHandler)
    }
    
    
    init(searchHandler: PersonSearchHandler<H>, selectionHandler: SearchSelectedObjectHandler) {
        super.init(searchHandler.searchNavigationDelegate, selectionHandler: selectionHandler)
        
        let buttonAction = SearchButtonAction()
        buttonAction.label = "label_complete_selection".translated()
        buttonAction.onClick = { [unowned self] in
            self.notifyDidSelect()
            self.searchTextDelegate?.finishSearch()
        }
        
        let doneButtonSection = SearchButtonSection<Person>(headerTitle: nil, rowAction: buttonAction)
        var sections = createPersonsSearchSections(
            searchHandler: searchHandler,
            rowIdentifier: SelectablePersonCell.identifier,
            titleKey: "persons") { [unowned self] cell, person in
                if let personCell = cell as? SelectablePersonCell {
                    personCell.updateFrom(person: person)
                    personCell.isSelectedForParent = self.isSelected(id: person.id)
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
        tableView.register(SelectablePersonCell.self, forCellReuseIdentifier: SelectablePersonCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createPersonsSearchSections<H: HandlerModel>(
    searchHandler: PersonSearchHandler<H>,
    rowIdentifier: String,
    titleKey: String,
    setupCellCallback: @escaping (UITableViewCell, Person) -> Void) -> [SearchTemplateSection<Person>] {
    
    let sortAction = SearchSortAction<Person>()
    sortAction.label = "label_title_sorted_by".translated()
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "ic_date_range_white")!, label: "decedent_birthday".translated()) {
            let lhsDeath = $0.birthday
            let rhsDeath = $1.birthday
            return lhsDeath?.timeIntervalSince1970 ?? 0 < rhsDeath?.timeIntervalSince1970 ?? 0
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "decedent_forename".translated()) {
            let lhsName = $0.first_name ?? ""
            let rhsName = $1.first_name ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        },
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "decedent_nickname".translated()) {
            let lhsName = $0.nickname ?? ""
            let rhsName = $1.nickname ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Person>()
    let dataSection = SearchDataSection<Person>(rowIdentifier: rowIdentifier,
                                                headerIdentifier: CountSectionHeader.identifier,
                                                rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: titleKey, count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<Person>(headerTitle: "", rowAction: sortAction),
            dataSection]
}



final class PersonSearchHandler<H: HandlerModel>: SearchableObjectHandler<Person> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<Person>?
    var handler: TemplateCoreDataHandler<H>!
    
    override func isIncluded(_ object: Person, filterByText text: String) -> Bool {
        return text.isEmpty
            || object.first_name?.localizedCaseInsensitiveContains(text) ?? false
            || object.last_name?.localizedCaseInsensitiveContains(text) ?? false
            || object.birth_name?.localizedCaseInsensitiveContains(text) ?? false
    }
    
    
    override func selectedRow(with object: Person) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            handler.setupBeforeEditing(object)
            
            let detailedVC = PersonDetailedVC()
            detailedVC.selectedObject = object
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [Person] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
