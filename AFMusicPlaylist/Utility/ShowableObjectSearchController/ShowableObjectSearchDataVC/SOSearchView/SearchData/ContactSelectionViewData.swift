
import UIKit


final class ContactSelectionViewData<H: HandlerModel>: SOSearchData<SOContact> {
    private let callableModel = CallableListCellModel()
    
    
    init(searchHandler: ContactSearchHandler<H>, titleKey: String = "contacts",
         didSelectInfoButton: @escaping (SOContact) -> Void) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        let dataAction = SearchDataRowAction<SOContact>()
        let dataSection = SearchDataSection<SOContact>(
            rowIdentifier: ContactSelectionViewCell.identifier,
            headerIdentifier: nil,
            rowAction: dataAction)
        
        dataSection.searchableObjectDelegate = searchHandler
        dataAction.setupCellCallback = { [unowned self] cell, contact in
            if let contactCell = cell as? ContactSelectionViewCell {
                contactCell.didSelectInfoButton = didSelectInfoButton
                contactCell.updateFrom(contact: contact, model: self.callableModel)
            }
        }
        
        insertSections([dataSection])
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(ContactSelectionViewCell.self, forCellReuseIdentifier: ContactSelectionViewCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}
