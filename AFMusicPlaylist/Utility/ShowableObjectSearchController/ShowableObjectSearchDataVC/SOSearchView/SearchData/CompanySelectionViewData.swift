

import UIKit

final class CompanySelectionViewData<H: HandlerModel>: SOSearchData<Company> {
    private let callableModel = CallableListCellModel()
    
    
    init(searchHandler: CompanySearchHandler<H>, titleKey: String = "companies", didSelectInfoButton: @escaping (Company) -> Void) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        let dataAction = SearchDataRowAction<Company>()
        let dataSection = SearchDataSection<Company>(
            rowIdentifier: CompanySelectionViewCell.identifier,
            headerIdentifier: nil,
            rowAction: dataAction)
        
        dataSection.searchableObjectDelegate = searchHandler
        dataAction.setupCellCallback = { [unowned self] cell, company in
            if let companyCell = cell as? CompanySelectionViewCell {
                companyCell.updateFrom(company: company, model: self.callableModel)
                companyCell.didSelectInfoButton = didSelectInfoButton
            }
        }
        
        insertSections([dataSection])
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(CompanySelectionViewCell.self, forCellReuseIdentifier: CompanySelectionViewCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}
