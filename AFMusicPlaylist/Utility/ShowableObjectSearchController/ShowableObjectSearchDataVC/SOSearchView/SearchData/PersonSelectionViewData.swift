

import UIKit

final class PersonSelectionViewData<H: HandlerModel>: SOSearchData<Person> {
    init(searchHandler: PersonSearchHandler<H>, titleKey: String = "persons", didSelectInfoButton: @escaping (Person) -> Void) {
        super.init(searchNavigationDelegate: searchHandler.searchNavigationDelegate)
        
        let dataAction = SearchDataRowAction<Person>()
        let dataSection = SearchDataSection<Person>(
            rowIdentifier: PersonSelectionViewCell.identifier,
            headerIdentifier: nil,
            rowAction: dataAction)
        
        dataSection.searchableObjectDelegate = searchHandler
        dataAction.setupCellCallback = { cell, person in
            if let personCell = cell as? PersonSelectionViewCell {
                personCell.updateFrom(person: person)
                personCell.didSelectInfoButton = didSelectInfoButton
            }
        }
        
        insertSections([dataSection])
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(PersonSelectionViewCell.self, forCellReuseIdentifier: PersonSelectionViewCell.identifier)
        tableView.register(CountSectionHeader.self, forHeaderFooterViewReuseIdentifier: CountSectionHeader.identifier)
    }
}
