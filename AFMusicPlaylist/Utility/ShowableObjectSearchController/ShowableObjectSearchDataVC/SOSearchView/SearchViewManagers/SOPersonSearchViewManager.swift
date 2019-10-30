

import UIKit


final class SOPersonSearchViewManager<H: HandlerModel>: SOSearchViewManager<Person, H>,
SearchHandlerDataSource, SOFilterableSearchList {
    var filters = [SearchFilterPosition<Person>]()
    
    private let _isCreatingAllowed: Bool
    private let _associatedPersonGroup: PersonGroup?
    
    
    override init(searchLabel: String?, handler: TemplateCoreDataHandler<H>, inside view: UIView,
                  navDelegate: SearchNavigationDelegate?, didSelect: @escaping (Person) -> Void) {
        _associatedPersonGroup = nil
        _isCreatingAllowed = true
        super.init(searchLabel: searchLabel, handler: handler, inside: view, navDelegate: navDelegate, didSelect: didSelect)
    }
    
    
    init(associated personGroup: PersonGroup, isCreatingAllowed: Bool,
         searchLabel: String?, using handler: TemplateCoreDataHandler<H>, inside view: UIView,
         navDelegate: SearchNavigationDelegate?, didSelect: @escaping (Person) -> Void) {
        _associatedPersonGroup = personGroup
        _isCreatingAllowed = isCreatingAllowed
        super.init(searchLabel: searchLabel, handler: handler, inside: view, navDelegate: navDelegate, didSelect: didSelect)
    }
    
    
    func selectedRow(with object: Person) {
        let handler = CoreDataHandler.shared.personHandler
        
        if let validPerson = handler.getBy(id: object.id) {
            handler.setupBeforeEditing(validPerson)
            
            let personDetailed = PersonDetailedVC()
            personDetailed.selectedObject = validPerson
            personDetailed.entity = .person
            
            searchNavigationDelegate?.pushViewController(personDetailed)
        }
    }
    
    
    func fetchOriginalList() -> [Person] {
        if let group = _associatedPersonGroup {
            return Array(group.persons).apply(filters: filters)
        } else {
            return (CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []).apply(filters: filters)
        }
    }
    
    
    override func searchData() -> SOSearchData<Person>? {
        let searchHandler = PersonSearchHandler<H>()
        searchHandler.handler = handler
        searchHandler.dataSource = SearchDataSourceWrapper(self)
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        
        return PersonSelectionViewData<H>(searchHandler: searchHandler) { [weak self] person in
            let handler = CoreDataHandler.shared.personHandler
            
            if let validPerson = handler.getBy(id: person.id) {
                handler.setupBeforeEditing(validPerson)
                
                let actionButton = SOBarButton<PersonDetailedVC>(icon: UIImage.okImage) { [weak self] table in
                    self?.searchView?.close(animated: false)
                    self?.didSelectObject(person)
                    table?.navigationController?.popViewController(animated: true)
                }
                
                let personDetailed = PersonDetailedVC(additionalBarButtons: [actionButton])
                personDetailed.selectedObject = validPerson
                personDetailed.setModificationBlocked(true)
                
                self?.searchNavigationDelegate?.pushViewController(personDetailed)
            }
        }
    }
    
    override func searchAddButtonData(_ searchView: SOSearchView<Person>) -> [OptionButtonData] {
        return [
            OptionButtonData { [weak self] in
                let person = CoreDataHandler.shared.personHandler.createObjectInChildContext()
                let actionButton = SOBarButton<PersonDetailedVC>(icon: UIImage.okImage) { [weak self] table in
                    table?.onSave()
                    
                    if let handler = self?.handler, let validPerson = CoreDataHandler.shared.personHandler.getBy(
                        id: person.id, context: handler.localManagedContext) {
                        self?._associatedPersonGroup?.persons.insert(validPerson)
                        self?.didSelectObject(validPerson)
                    }
                    
                    self?.searchView?.close(animated: false)
                    table?.navigationController?.popViewController(animated: true)
                }
                
                let detailedVC = PersonDetailedVC(additionalBarButtons: [actionButton])
                detailedVC.selectedObject = person
                detailedVC.setNeedsEditModeOnLoad(skipModificationCheck: true)
                detailedVC.setModificationBlocked(true)
                
                self?.searchNavigationDelegate?.pushViewController(detailedVC)
            }
        ]
    }
    
    
    override func searchCanCreateObjects(_ searchView: SOSearchView<Person>) -> Bool {
        return PermissionValidator.sh.any(.person, .create).check() && _isCreatingAllowed
    }
}
