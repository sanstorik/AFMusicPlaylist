
import UIKit

final class SelectableBundleTemplateSearchDataVC<H: HandlerModel>: SelectableSearchDataVC<BundleTemplate> {
    convenience init(searchNavigationDelegate: SearchNavigationDelegate?,
                     handler: TemplateCoreDataHandler<H>,
                     selectionHandler: SearchSelectedObjectHandler) {
        let searchHandler = BundleTemplateSearchHandler<H>()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        searchHandler.handler = handler
        
        self.init(searchHandler: searchHandler, selectionHandler: selectionHandler)
    }
    
    
    init(searchHandler: BundleTemplateSearchHandler<H>, selectionHandler: SearchSelectedObjectHandler) {
        super.init(searchHandler.searchNavigationDelegate, selectionHandler: selectionHandler)
        
        let buttonAction = SearchButtonAction()
        buttonAction.label = "label_complete_selection".translated()
        buttonAction.onClick = { [unowned self] in
            self.notifyDidSelect()
            self.searchTextDelegate?.finishSearch()
        }
        
        let doneButtonSection = SearchButtonSection<BundleTemplate>(headerTitle: nil, rowAction: buttonAction)
        var sections = createBundleTemplatesSearchSections(
            searchHandler: searchHandler,
            rowIdentifier: SelectableBundleCell.identifier) { [unowned self] cell, bundleTemplate in
                if let bundleTemplateCell = cell as? SelectableBundleCell {
                    bundleTemplateCell.isPriceCategoryPickerNeeded = false
                    bundleTemplateCell.updateFrom(bundleTemplate: bundleTemplate)
                    bundleTemplateCell.isSelectedForParent = self.isSelected(id: bundleTemplate.id)
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
        tableView.register(SelectableBundleCell.self, forCellReuseIdentifier: SelectableBundleCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}


fileprivate func createBundleTemplatesSearchSections<H: HandlerModel>(
    searchHandler: BundleTemplateSearchHandler<H>,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, BundleTemplate) -> Void) -> [SearchTemplateSection<BundleTemplate>] {
    
    let sortAction = SearchSortAction<BundleTemplate>()
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
        UISearchSortPosition(image: UIImage(named: "ic_text_icon")!, label: "label".translated()) {
            let lhsName = $0.label ?? ""
            let rhsName = $1.label ?? ""
            let result = lhsName.compare(rhsName)
            return result == .orderedAscending || result == .orderedSame
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<BundleTemplate>()
    let dataSection = SearchDataSection<BundleTemplate>(rowIdentifier: rowIdentifier,
                                               headerIdentifier: CountSectionHeader.identifier,
                                               rowAction: dataAction)
    
    dataSection.searchableObjectDelegate = searchHandler
    dataAction.setupCellCallback = setupCellCallback
    
    dataAction.setupHeaderCallback = { cell, list in
        if let countHeader = cell as? CountSectionHeader {
            let labelSection = LabelDataSection(title:
                CountSectionHeader.countLabel(key: "bundles", count: list.count))
            countHeader.item = labelSection
            countHeader.isFilterButtonHidden = true
        }
    }
    
    return [SearchSortSection<BundleTemplate>(headerTitle: "", rowAction: sortAction),
            dataSection]
}


final class BundleTemplateSearchHandler<H: HandlerModel>: SearchableObjectHandler<BundleTemplate> {
    weak var searchNavigationDelegate: SearchNavigationDelegate?
    var dataSource: SearchDataSourceWrapper<BundleTemplate>?
    var handler: TemplateCoreDataHandler<H>!
    
    override func isIncluded(_ object: BundleTemplate, filterByText: String) -> Bool {
        return filterByText.isEmpty
            || object.descriptionValue?.contains(filterByText) ?? false
            || object.label?.contains(filterByText) ?? false
    }
    
    
    override func selectedRow(with object: BundleTemplate) {
        if let _dataSource = dataSource {
            _dataSource.selectedRow(with: object)
        } else {
             handler.setupBeforeEditing(object)
             
             let detailedVC = BundleTemplateDetailedDataVC()
             detailedVC.selectedObject = object
             searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    override func fetchOriginalList() -> [BundleTemplate] {
        return dataSource?.fetchOriginalList()
            ?? CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []
    }
}
