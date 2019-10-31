

import UIKit


class AFArtistSearchDataVC: SOSearchData<AFArtist> {
    override init(searchNavigationDelegate: SearchNavigationDelegate?) {
        super.init(searchNavigationDelegate: searchNavigationDelegate)
        
        let searchHandler = AFArtistSearchHandler()
        searchHandler.searchNavigationDelegate = searchNavigationDelegate
        
        insertSections(
            createAFArtistsSearchSections(
                searchHandler: searchHandler,
                rowIdentifier: AFArtistCell.identifier) { cell, artist in
                    if let artistCell = cell as? AFArtistCell {
                        artistCell.artist = artist
                    }
        })
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func registerCustomDataCells(_ tableView: UITableView) {
        super.registerCustomDataCells(tableView)
        tableView.register(AFArtistCell.self, forCellReuseIdentifier: AFArtistCell.identifier)
        tableView.register(SortCell<AFArtist>.self, forCellReuseIdentifier: SortCell<AFArtist>.identifier)
    }
}


fileprivate func createAFArtistsSearchSections(
    searchHandler: AFArtistSearchHandler,
    rowIdentifier: String,
    setupCellCallback: @escaping (UITableViewCell, AFArtist) -> Void) -> [SearchTemplateSection<AFArtist>] {
    
    let sortAction = SearchSortAction<AFArtist>()
    sortAction.label = "Sorted by"
    sortAction.sortPositions = [
        UISearchSortPosition(image: UIImage(named: "name_icon")!, label: "Name") {
            $0.name ?? "" < $1.name ?? ""
        },
        UISearchSortPosition(image: UIImage(named: "fan_icon")!, label: "Fans") {
            $0.listeners < $1.listeners
        },
        UISearchSortPosition(image: UIImage(named: "date_icon")!, label: "Something") {
            $0.name ?? "" < $1.name ?? ""
        }
    ]
    
    sortAction.selectedSortPosition = sortAction.sortPositions.first
    
    let dataAction = SearchDataRowAction<AFArtist>()
    let dataSection = SearchDataSection<AFArtist>(
        rowIdentifier: rowIdentifier, headerIdentifier: nil, rowAction: dataAction
    )
    
    dataAction.setupCellCallback = setupCellCallback
    dataSection.searchableObjectDelegate = searchHandler
    return [SearchSortSection<AFArtist>(headerTitle: "", rowAction: sortAction), dataSection]
}


final class AFArtistSearchHandler: SearchableObjectHandler<AFArtist> {
    //var dataSource: SearchDataSourceWrapper<AFArtist>?
    weak var searchNavigationDelegate: SearchNavigationDelegate?

    
    override func selectedRow(with object: AFArtist) {
        
    }
    
    
    override func loadItems(at page: Int, with limits: Int, filteredBy text: String?, didLoad: ([AFArtist]) -> Void) {
        didLoad([
            AFArtist(name: "first", images: [], listeners: 0),
            AFArtist(name: "second", images: [], listeners: 0)]
        )
    }
}
