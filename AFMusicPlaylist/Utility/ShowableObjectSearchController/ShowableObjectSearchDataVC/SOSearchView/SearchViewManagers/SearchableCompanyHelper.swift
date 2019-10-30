
import UIKit

class SearchableCompanyHelper<H: HandlerModel> {
    private let _searchNavigationDelegate: SearchNavigationDelegate?
    private let _handler: TemplateCoreDataHandler<H>
    
    
    init(searchNavigationDelegate: SearchNavigationDelegate?, handler: TemplateCoreDataHandler<H>) {
        self._searchNavigationDelegate = searchNavigationDelegate
        self._handler = handler
    }
    
    
    func didSelectRowWith(company: Company) {
        _handler.setupBeforeEditing(company)
        let detailedVC = CompanyDetailedVC<H>(shouldDiscardChanges: false, displayEntrySection: true)
        detailedVC.handler = _handler
        detailedVC.selectedObject = company
        detailedVC.isSearchPossible = false
        detailedVC.titleKey = "contacts"
        
        _searchNavigationDelegate?.pushViewController(detailedVC)
    }
    
    
    func didSelectAddNewCompany(company: Company, actionButtons: [SOBarButton<CompanyDetailedVC<H>>]) {
        _handler.setupBeforeEditing(company)
        _handler.createdObjects.append(company)
        
        let detailedVC = CompanyDetailedVC<H>(
            shouldDiscardChanges: false, displayEntrySection: true, additionalBarButtons: actionButtons
        )
        
        detailedVC.handler = _handler
        detailedVC.selectedObject = company
        detailedVC.isSearchPossible = false
        detailedVC.setNeedsEditModeOnLoad(skipModificationCheck: true)
        detailedVC.setModificationBlocked(true)
        
        _searchNavigationDelegate?.pushViewController(detailedVC)
    }
    
    
    func didSelectOptionRowButtonWith(company: Company, actionButtons: [SOBarButton<CompanyDetailedVC<H>>]) {
        _handler.setupBeforeEditing(company)
        
        let detailedVC = CompanyDetailedVC<H>(shouldDiscardChanges: false, displayEntrySection: true,
                                              additionalBarButtons: actionButtons)
        detailedVC.handler = _handler
        detailedVC.selectedObject = company
        detailedVC.isSearchPossible = false
        detailedVC.titleKey = "contacts"
        detailedVC.setModificationBlocked(true)
        
        _searchNavigationDelegate?.pushViewController(detailedVC)
    }
}
