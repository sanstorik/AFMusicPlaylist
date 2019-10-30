

import UIKit


final class SOCompanySearchViewManager<H: HandlerModel>: SOSearchViewManager<Company, H>,
SearchHandlerDataSource, SOFilterableSearchList {
    var filters = [SearchFilterPosition<Company>]()
    private let _companyHelper: SearchableCompanyHelper<H>
    
    
    override init(searchLabel: String?, handler: TemplateCoreDataHandler<H>, inside view: UIView,
                  navDelegate: SearchNavigationDelegate?, didSelect: @escaping (Company) -> Void) {
        self._companyHelper = SearchableCompanyHelper<H>(searchNavigationDelegate: navDelegate, handler: handler)
        super.init(searchLabel: searchLabel, handler: handler, inside: view, navDelegate: navDelegate, didSelect: didSelect)
    }
    
    
    func selectedRow(with object: Company) {
        _companyHelper.didSelectRowWith(company: object)
    }
    
    
    func fetchOriginalList() -> [Company] {
        return (CoreDataHandler.shared.fetch(in: handler.localManagedContext) ?? []).apply(filters: filters)
    }
    
    
    override func searchData() -> SOSearchData<Company>? {
        let searchHandler = CompanySearchHandler<H>(titleKey: "companies")
        searchHandler.handler = handler
        searchHandler.dataSource = SearchDataSourceWrapper(self)
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        
        return CompanySelectionViewData<H>(searchHandler: searchHandler) { [weak self] company in
            let actionButton = SOBarButton<CompanyDetailedVC<H>>(icon: UIImage.okImage) { [weak self] table in
                self?.searchView?.close(animated: false)
                self?.didSelectObject(company)
                table?.navigationController?.popViewController(animated: true)
            }
            
            self?._companyHelper.didSelectOptionRowButtonWith(company: company, actionButtons: [actionButton])
        }
    }
    
    override func searchAddButtonData(_ searchView: SOSearchView<Company>) -> [OptionButtonData] {
        return [
            OptionButtonData { [weak self] in
                guard let nHandler = self?.handler else { return }
                
                let company = Company(context: nHandler.localManagedContext)
                let actionButton = SOBarButton<CompanyDetailedVC<H>>(icon: UIImage.okImage) { [weak self] table in
                    table?.onSave()
                    
                    self?.didSelectObject(company)
                    self?.searchView?.close(animated: false)
                    table?.navigationController?.popViewController(animated: true)
                }
                
                self?._companyHelper.didSelectAddNewCompany(company: company, actionButtons: [actionButton])
            }
        ]
    }
    
    
    override func searchCanCreateObjects(_ searchView: SOSearchView<Company>) -> Bool {
        return PermissionValidator.sh.any(.company, .create).check()
    }
}
