
import UIKit


class SearchDataRowAction<T>: SearchRowAction {
    var setupCellCallback: ((UITableViewCell, T) -> Void)?
    var setupHeaderCallback: ((UITableViewHeaderFooterView, [T]) -> Void)?
}

protocol UpdatableSearchRowAction: SearchRowAction {
    var searchPositionDidUpdate: (() -> ())? { get set }
}

protocol SearchRowAction: class { }


class SearchTemplateSection<T> {
    var rowAction: SearchRowAction
    var headerTitle: String?
    
    open var rowsCount: Int { return 0 }
    open var useHeader: Bool { return true }
    open var headerIdentifier: String { return "template_identifier" }
    open var rowIdentifier: String { return "" }
    
    open func rowHeightFor(frame: CGRect) -> CGFloat {
        return frame.deviceHeight * 0.2
    }
    
    init(headerTitle: String?, rowAction: SearchRowAction) {
        self.rowAction = rowAction
        self.headerTitle = headerTitle
    }
}

class SearchSection<T>: SearchTemplateSection<T> { }

// #MARK: Filtering data

final class SearchFilteringSection<T>: SearchSection<T> {
    override var rowsCount: Int { return 1 }
    override var rowIdentifier: String { return SortCell<T>.identifier }
    override var useHeader: Bool { return false }
}


final class SearchFilterAction<T>: UpdatableSearchRowAction {
    var searchPositionDidUpdate: (() -> ())?
    var filterPositions = [UISearchFilterPosition<T>]()
    var label: String?
}

// #MARK: Sorting data

final class SearchSortSection<T>: SearchSection<T> {
    override var rowsCount: Int { return 1 }
    override var rowIdentifier: String { return SortCell<T>.identifier }
    override var useHeader: Bool { return false }
    
    override func rowHeightFor(frame: CGRect) -> CGFloat {
        return (frame.deviceHeight * 0.24).with(min: 190, max: 300)
    }
}


final class SearchSortAction<T>: UpdatableSearchRowAction {
    var label: String?
    var sortPositions = [UISearchSortPosition<T>]()
    var searchPositionDidUpdate: (() -> ())?
    var selectedSortPosition: UISearchSortPosition<T>?
    var sortByAscendingOrder = true
    
    final var selectedSortPositionIndex: Int? {
        if let selected = selectedSortPosition {
            return sortPositions.firstIndex { $0.label == selected.label }
        }
        
        return nil
    }
}



// #MARK: Displaying data


protocol SearchableDataSection: class {
    associatedtype SearchableObject
    var requiresPagination: Bool { get }
    
    func filterByStringAsync(_ text: String?, filterCollector: SearchFilterCollector<SearchableObject>,
                             didLoadItems: @escaping () -> Void)
    func performPagination(_ text: String?, _ didFetchItems: @escaping ([Int]) -> Void)
    func sortObjects(_ text: String?, filterCollector: SearchFilterCollector<SearchableObject>)
    func isReadyToPerformPagination(displaying row: Int) -> Bool
}


protocol ISearchableObjectDelegate: class {
    associatedtype SearchableObject
    func selectedRow(with object: SearchableObject)
    func loadItems(at page: Int, with limits: Int, filteredBy text: String?, didLoad: @escaping ([SearchableObject]) -> Void)
}


class SearchableObjectHandler<T>: ISearchableObjectDelegate {
    typealias SearchableObject = T
    
    open func selectedRow(with object: T) { }
    open func loadItems(at page: Int, with limits: Int, filteredBy text: String?, didLoad: @escaping ([T]) -> Void) {
        didLoad([])
    }
}


final class SearchDataSection<T>: SearchTemplateSection<T>, SearchableDataSection {
    typealias SearchableObject = T
    
    override var rowsCount: Int { return resultingList.count }
    override var rowIdentifier: String { return dataRowIdentifier }
    override var headerIdentifier: String { return dataHeaderIdentifier ?? "" }
    override var useHeader: Bool { return dataHeaderIdentifier != nil }
    
    var requiresPagination: Bool { return lastPaginationBatch >= pageLimit }
    var searchableObjectDelegate: SearchableObjectHandler<T>?
    private(set) var resultingList = [T]()
    
    private let dataRowIdentifier: String
    private let dataHeaderIdentifier: String?
    private let pageLimit = 30
    private var currentPage = 1
    private var lastPaginationBatch = 30
    
    
    init(rowIdentifier: String, headerIdentifier: String?, rowAction: SearchRowAction) {
        self.dataRowIdentifier = rowIdentifier
        self.dataHeaderIdentifier = headerIdentifier
        super.init(headerTitle: nil, rowAction: rowAction)
    }
    
    
    override func rowHeightFor(frame: CGRect) -> CGFloat {
        return (frame.deviceHeight / 6.5).with(min: 70, max: 90)
    }
    

    func selectedRow(at row: Int) {
        self.searchableObjectDelegate?.selectedRow(with: resultingList[row])
    }
    
    
    func filterByStringAsync(_ text: String?, filterCollector: SearchFilterCollector<T>, didLoadItems: @escaping () -> Void) {
        currentPage = 1
        searchableObjectDelegate?.loadItems(at: currentPage, with: pageLimit, filteredBy: text) {
            self.resultingList = $0.apply(filters: filterCollector.filteringPositions)
                .apply(sorting: filterCollector.sortingPositions, ascendingOrder: filterCollector.sortAscending)
            didLoadItems()
        }
    }
    
    
    func performPagination(_ text: String?, _ didFetchItems: @escaping ([Int]) -> Void) {
        currentPage += 1
        searchableObjectDelegate?.loadItems(at: currentPage, with: pageLimit, filteredBy: text) { [currentPage] in
            self.resultingList += $0
            let insertedRows = self.createIndeciesForPage(currentPage, inserted: $0.count)
            didFetchItems(insertedRows)
            self.lastPaginationBatch = $0.count
        }
    }
    
    
    func isReadyToPerformPagination(displaying row: Int) -> Bool {
        return row > (currentPage * pageLimit) - pageLimit / 2
    }
    
    
    func sortObjects(_ text: String?, filterCollector: SearchFilterCollector<T>) {
        resultingList = resultingList.apply(sorting: filterCollector.sortingPositions, ascendingOrder: filterCollector.sortAscending)
    }
    
    
    private func createIndeciesForPage(_ page: Int, inserted count: Int) -> [Int] {
        let offset = pageLimit * (page - 1)
        var indecies = [Int]()
        
        for i in offset..<offset + count {
            indecies.append(i)
        }
        
        return indecies
    }
}


// #MARK: Simple button action

final class SearchButtonSection<T>: SearchSection<T> {
    override var rowsCount: Int { return 1 }
    override var rowIdentifier: String { return ButtonCell<T>.identifier }
    override var useHeader: Bool { return false }
    
    override func rowHeightFor(frame: CGRect) -> CGFloat {
        return (frame.deviceHeight * 0.11).with(min: 30, max: 50)
    }
}

class SearchButtonAction: SearchRowAction {
    var label: String?
    var onClick: (() -> ())?
}
