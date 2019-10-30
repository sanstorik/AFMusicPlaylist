
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
    open var headerIdentifier: String { return LabelCellHeader.identifier }
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
    func filterByString(_ text: String?, filterCollector: SearchFilterCollector<SearchableObject>)
}


protocol ISearchableObjectDelegate: class {
    associatedtype SearchableObject
    func isIncluded(_ object: SearchableObject, filterByText: String) -> Bool
    func selectedRow(with object: SearchableObject)
    func fetchOriginalList() -> [SearchableObject]
}


class SearchableObjectHandler<T>: ISearchableObjectDelegate {
    typealias SearchableObject = T
    
    open func isIncluded(_ object: T, filterByText text: String) -> Bool { return true }
    open func selectedRow(with object: T) { }
    open func fetchOriginalList() -> [T] { return [] }
}


final class SearchDataSection<T>: SearchTemplateSection<T>, SearchableDataSection {
    typealias SearchableObject = T
    
    override var rowsCount: Int { return resultingList.count }
    override var rowIdentifier: String { return dataRowIdentifier }
    override var headerIdentifier: String { return dataHeaderIdentifier ?? "" }
    override var useHeader: Bool { return dataHeaderIdentifier != nil }
    
    var searchableObjectDelegate: SearchableObjectHandler<T>? {
        didSet {
            updateOriginalList()
        }
    }
    
    private(set) var originalList = [T]()
    private(set) var resultingList = [T]()
    
    private let dataRowIdentifier: String
    private let dataHeaderIdentifier: String?
    
    
    init(rowIdentifier: String, headerIdentifier: String?, rowAction: SearchRowAction) {
        self.dataRowIdentifier = rowIdentifier
        self.dataHeaderIdentifier = headerIdentifier
        super.init(headerTitle: nil, rowAction: rowAction)
    }
    
    
    override func rowHeightFor(frame: CGRect) -> CGFloat {
        return (frame.deviceHeight / 7.45).with(min: 95, max: 150)
    }
    
    
    func filterByString(_ text: String?, filterCollector: SearchFilterCollector<T>) {
        var _collector = filterCollector
        if let filterText = text, !filterText.isEmpty {
            _collector = _collector.byAddingFilter {
                self.searchableObjectDelegate?.isIncluded($0, filterByText: filterText) ?? true
            }
        }

        resultingList = originalList.apply(collector: _collector)
    }
    
    
    func updateOriginalList() {
        originalList = searchableObjectDelegate?.fetchOriginalList() ?? []
    }
    
    
    func selectedRow(at row: Int) {
        self.searchableObjectDelegate?.selectedRow(with: resultingList[row])
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
