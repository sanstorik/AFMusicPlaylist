

import UIKit


final class SOContactSearchViewManager<H: HandlerModel>: SOSearchViewManager<SOContact, H>,
SearchHandlerDataSource, SOFilterableSearchList {
    var filters = [SearchFilterPosition<SOContact>]()
    private let _companyHelper: SearchableCompanyHelper<H>
    
    
    override init(searchLabel: String?, handler: TemplateCoreDataHandler<H>, inside view: UIView,
                  navDelegate: SearchNavigationDelegate?, didSelect: @escaping (SOContact) -> Void) {
        self._companyHelper = SearchableCompanyHelper<H>(searchNavigationDelegate: navDelegate, handler: handler)
        super.init(searchLabel: searchLabel, handler: handler, inside: view, navDelegate: navDelegate, didSelect: didSelect)
    }
    
    
    func selectedRow(with object: SOContact) {
        if let company = object.company {
            _companyHelper.didSelectRowWith(company: company)
        } else if let person = object.person, let valid = CoreDataHandler.shared.personHandler.getBy(id: person.id) {
            CoreDataHandler.shared.personHandler.setupBeforeEditing(valid)
            let detailedVC = PersonDetailedVC()
            detailedVC.selectedObject = valid
            
            searchNavigationDelegate?.pushViewController(detailedVC)
        }
    }
    
    
    func fetchOriginalList() -> [SOContact] {
        return SOContact.fetchFromDatabase(for: handler, readDeleted: .none).apply(filters: filters)
    }
    
    
    override func searchData() -> SOSearchData<SOContact>? {
        let searchHandler = ContactSearchHandler<H>(titleKey: "contacts")
        searchHandler.handler = handler
        searchHandler.dataSource = SearchDataSourceWrapper(self)
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        
        return ContactSelectionViewData<H>(searchHandler: searchHandler) { [weak self] contact in
            if let company = contact.company {
                let actionButton = SOBarButton<CompanyDetailedVC<H>>(icon: UIImage.okImage) { [weak self] table in
                    self?.searchView?.close(animated: false)
                    self?.didSelectObject(contact)
                    table?.navigationController?.popViewController(animated: true)
                }
                
                self?._companyHelper.didSelectOptionRowButtonWith(company: company, actionButtons: [actionButton])
            } else if let person = contact.person, let valid = CoreDataHandler.shared.personHandler.getBy(id: person.id) {
                CoreDataHandler.shared.personHandler.setupBeforeEditing(valid)
                
                let actionButton = SOBarButton<PersonDetailedVC>(icon: UIImage.okImage) { [weak self] table in
                    self?.searchView?.close(animated: false)
                    self?.didSelectObject(contact)
                    table?.navigationController?.popViewController(animated: true)
                }
                
                let detailedVC = PersonDetailedVC(additionalBarButtons: [actionButton])
                detailedVC.selectedObject = valid
                detailedVC.setModificationBlocked(true)
                
                self?.searchNavigationDelegate?.pushViewController(detailedVC)
            }
        }
    }
    
    
    override func searchAddButtonData(_ searchView: SOSearchView<SOContact>) -> [OptionButtonData] {
        var data = [OptionButtonData]()
        
        if PermissionValidator.sh.all(.person, .create).check() {
            data += [
                OptionButtonData(
                    color: AppColors.headerColor,
                    icon: UIImage(named: "icon_private_person")!,
                    text: "label_private_person".translated())
                { [unowned self] in
                    self.addNewPerson()
                }
            ]
        }
        
        if PermissionValidator.sh.all(.company, .create).check() {
            data += [
                OptionButtonData(color: AppColors.headerColor,
                                 icon: UIImage(named: "icon_company")!,
                                 text: "company".translated())
                { [unowned self] in
                    self.addNewCompany()
                },
                
                OptionButtonData(color: AppColors.headerColor,
                                 icon: UIImage(named: "icon_company_authority")!,
                                 text: "label_company_authority".translated())
                { [unowned self] in
                    self.addNewCompany()
                }
            ]
        }
    
        return data
    }
    
    
    override func searchCanCreateObjects(_ searchView: SOSearchView<SOContact>) -> Bool {
        return PermissionValidator.sh.any(.person, .create).or().any(.company, .create).check()
    }
    
    
    private func addNewCompany() {
        let company = Company(context: handler.localManagedContext)
        
        let actionButton = SOBarButton<CompanyDetailedVC<H>>(icon: UIImage.okImage) { [weak self] table in
            table?.onSave()
            
            self?.didSelectObject(SOContact(company: company))
            self?.searchView?.close(animated: false)
            table?.navigationController?.popViewController(animated: true)
        }

        _companyHelper.didSelectAddNewCompany(company: company, actionButtons: [actionButton])
    }
    
    
    private func addNewPerson() {
        let person = CoreDataHandler.shared.personHandler.createObjectInChildContext()
        let actionButton = SOBarButton<PersonDetailedVC>(icon: UIImage.okImage) { [weak self] table in
            table?.onSave()
            
            if let handler = self?.handler, let validPerson = CoreDataHandler.shared.personHandler.getBy(
                id: person.id, context: handler.localManagedContext) {
                self?.didSelectObject(SOContact(person: validPerson))
            }
            
            self?.searchView?.close(animated: false)
            table?.navigationController?.popViewController(animated: true)
        }
        
        let detailedVC = PersonDetailedVC(additionalBarButtons: [actionButton])
        detailedVC.selectedObject = person
        detailedVC.setNeedsEditModeOnLoad(skipModificationCheck: true)
        detailedVC.setModificationBlocked(true)
        
        searchNavigationDelegate?.pushViewController(detailedVC)
    }
}
