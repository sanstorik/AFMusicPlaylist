
import UIKit


final class AppointmentSearchDataVC<T: HandlerModel>: RefreshableSortedSearchDataVC<Appointment> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<T>) {
        let searchHandler = AppointmentSearchHandler<T>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler)
    }
    
    
    init(searchHandler: AppointmentSearchHandler<T>) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        insertSections(
            createAppointmentsSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: EventListCell.identifier) { cell, appointment in
                    if let appointmentCell = cell as? EventListCell {
                        appointmentCell.updateFrom(appointment: appointment)
                        
                        if let orderNumber = appointment.order?.orderNumber {
                            appointmentCell.top = "\("order_number".translated()): \(orderNumber)"
                        } else {
                            appointmentCell.top = "message_no_assigned_order".translated()
                        }
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


fileprivate func createAppointmentsSearchSections<T: HandlerModel>(
    searchHandler: AppointmentSearchHandler<T>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, Appointment) -> Void) -> [SearchTemplateSection<Appointment>] {
    
    let sortAction = SearchSortAction<Appointment>()
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
            let lhsDeath = $0.until_datetime
            let rhsDeath = $1.until_datetime
            return lhsDeath?.timeIntervalSince1970 ?? 0 < rhsDeath?.timeIntervalSince1970 ?? 0
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<Appointment>()
    let dataSection = SearchDataSection<Appointment>(rowIdentifier: rowIdentifier,
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
    
    return [SearchSortSection<Appointment>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class AppointmentSearchHandler<T: HandlerModel>: SearchableObjectHandler<Appointment> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<Appointment>?
    var handler: TemplateCoreDataHandler<T>!
    
    override func isIncluded(_ object: Appointment, filterByText: String) -> Bool {
        let doesOrderNumberFit = object.order?.orderNumber?.contains(filterByText) ?? false
        return filterByText.isEmpty
            || object.shortText?.contains(filterByText) ?? false
            || object.longText?.contains(filterByText) ?? false
            || doesOrderNumberFit
    }
    
    
    override func selectedRow(with object: Appointment) {
        CoreDataHandler.shared.appointmentHandler.setupBeforeEditing(object)
        
        let detailedVC = EventDetailVC()
        detailedVC.selectedObject = object
        
        searchNavigationDelegate?.pushViewController(detailedVC)
    }
    
    
    override func fetchOriginalList() -> [Appointment] {
        return dataSource?.fetchOriginalList() ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
