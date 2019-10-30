
import UIKit

final class AppointmentTemplateSearchDataVC<H: HandlerModel>: RefreshableSortedSearchDataVC<AppointmentTemplate> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
         handler: TemplateCoreDataHandler<H>) {
        let searchHandler = AppointmentTemplateSearchHandler<H>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: AppointmentTemplateSearchHandler<H>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createAppointmentTemplatesSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: EventListCell.identifier) { cell, appointmentTemplate in
                    if let appointmentTemplateCell = cell as? EventListCell {
                        appointmentTemplateCell.updateFrom(template: appointmentTemplate)
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(EventListCell.self, forCellReuseIdentifier: EventListCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


final class SelectableAppointmentTemplateSearchDataVC<H: HandlerModel>: SelectableSearchDataVC<AppointmentTemplate> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
         handler: TemplateCoreDataHandler<H>,
         selectionHandler: SearchSelectedObjectHandler) {
        let searchHandler = AppointmentTemplateSearchHandler<H>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler, selectionHandler: selectionHandler)
    }
    
    
    init(searchHandler: AppointmentTemplateSearchHandler<H>,
         selectionHandler: SearchSelectedObjectHandler) {
        super.init(searchHandler.searchNavigationDelegate, selectionHandler: selectionHandler)
        
        let buttonAction = SearchButtonAction()
        buttonAction.label = "label_complete_selection".translated()
        buttonAction.onClick = { [unowned self] in
            self.notifyDidSelect()
            self.searchTextDelegate?.finishSearch()
        }
        
        let doneButtonSection = SearchButtonSection<AppointmentTemplate>(headerTitle: nil, rowAction: buttonAction)
        var sections = createAppointmentTemplatesSearchSections(
            searchHandler: searchHandler,
            rowIdentifier: SelectableEventCell.identifier) { [unowned self] cell, appointmentTemplate in
                if let appointmentTemplateCell = cell as? SelectableEventCell {
                    appointmentTemplateCell.updateFrom(template: appointmentTemplate)
                    appointmentTemplateCell.isSelectedForParent = self.isSelected(id: appointmentTemplate.id)
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
        tableView.register(SelectableEventCell.self, forCellReuseIdentifier: SelectableEventCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createAppointmentTemplatesSearchSections<H: HandlerModel>(
    searchHandler: AppointmentTemplateSearchHandler<H>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, AppointmentTemplate) -> Void) -> [SearchTemplateSection<AppointmentTemplate>] {
    
    let sortAction = SearchSortAction<AppointmentTemplate>()
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
    
    let dataAction = SearchDataRowAction<AppointmentTemplate>()
    let dataSection = SearchDataSection<AppointmentTemplate>(rowIdentifier: rowIdentifier,
                                                      headerIdentifier: CountSectionHeader.identifier,
                                                      rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: "appointments", count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<AppointmentTemplate>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class AppointmentTemplateSearchHandler<H: HandlerModel>: SearchableObjectHandler<AppointmentTemplate> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<AppointmentTemplate>?
    var handler: TemplateCoreDataHandler<H>!
    
    override func isIncluded(_ object: AppointmentTemplate, filterByText: String) -> Bool {
        return filterByText.isEmpty
            || object.shortText?.contains(filterByText) ?? false
            || object.longText?.contains(filterByText) ?? false
            || object.statementText?.contains(filterByText) ?? false
    }
    
    
    override func selectedRow(with object: AppointmentTemplate) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
            handler.setupBeforeEditing(object)
            
            let detailedVC = EventTemplateDetailVC()
            detailedVC.selectedObject = object
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [AppointmentTemplate] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
