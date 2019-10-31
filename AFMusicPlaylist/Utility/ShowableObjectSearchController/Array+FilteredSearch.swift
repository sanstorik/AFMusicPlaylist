
import UIKit


struct SearchFilterCollector<T> {
    final class Builder {
        private var sortingPositions = [SearchSortPosition<T>]()
        private var filteringPositions = [SearchFilterPosition<T>]()
        private var sortAscending = true
        
        func addingSortPositions(_ sortPositions: [SearchSortPosition<T>]) -> Builder {
            sortingPositions.append(contentsOf: sortPositions)
            return self
        }
        
        func addingFilterPositions(_ filterPositions: [SearchFilterPosition<T>]) -> Builder {
            filteringPositions.append(contentsOf: filterPositions)
            return self
        }
        
        func setSortAscending(_ sortAscending: Bool) -> Builder {
            self.sortAscending = sortAscending
            return self
        }
        
        func build() -> SearchFilterCollector<T> {
            return SearchFilterCollector<T>(sortingPositions: sortingPositions,
                                            filteringPositions: filteringPositions,
                                            sortAscending: sortAscending)
        }
    }
    
    let sortingPositions: [SearchSortPosition<T>]
    let filteringPositions: [SearchFilterPosition<T>]
    let sortAscending: Bool
    
    func byAddingFilter(_ isIncluded: @escaping (T) -> Bool) -> SearchFilterCollector {
        var filters = filteringPositions
        let newFilter = SearchFilterPosition(isIncluded: isIncluded)
        filters.append(newFilter)
        
        return SearchFilterCollector(sortingPositions: sortingPositions, filteringPositions: filters,
                                     sortAscending: sortAscending)
    }
}


class SearchSortPosition<T> {
    let areInAscendingOrder: (T, T) -> Bool
    
    init(areInAscendingOrder: @escaping (T, T) -> Bool) {
        self.areInAscendingOrder = areInAscendingOrder
    }
}

final class UISearchSortPosition<T>: SearchSortPosition<T> {
    let image: UIImage
    let label: String
    
    init(image: UIImage, label: String, areInAscendingOrder: @escaping (T, T) -> Bool) {
        self.image = image
        self.label = label
        super.init(areInAscendingOrder: areInAscendingOrder)
    }
}


class SearchFilterPosition<T> {
    let isIncluded: (T) -> Bool
    
    init(isIncluded: @escaping (T) -> Bool) {
        self.isIncluded = isIncluded
    }
}


class UISearchFilterPosition<T>: SearchFilterPosition<T> {
    let label: String?
    
    init(label: String? = nil, isIncluded: @escaping (T) -> Bool) {
        self.label = label
        super.init(isIncluded: isIncluded)
    }
}


extension Array {
    func apply(filters: [SearchFilterPosition<Element>]) -> [Element] {
        let resulting = filter { object in
            for i in 0..<filters.count {
                if !filters[i].isIncluded(object) { return false }
            }
            
            return true
        }
        
        return resulting
    }
    
    
    func apply(collector: SearchFilterCollector<Element>) -> [Element] {
        return apply(filters: collector.filteringPositions)
            .apply(sorting: collector.sortingPositions, ascendingOrder: collector.sortAscending)
    }
    
    
    func apply(sorting: SearchSortPosition<Element>, ascendingOrder: Bool) -> [Element] {
        return apply(sorting: [sorting], ascendingOrder: ascendingOrder)
    }
    
    
    func apply(sorting: [SearchSortPosition<Element>], ascendingOrder: Bool) -> [Element] {
        if let sortingPosition = sorting.first {
            let sortingOrder: (Element, Element) -> Bool = {
                let areSorted = sortingPosition.areInAscendingOrder($0, $1)
                return ascendingOrder ? areSorted : !areSorted
            }
            
            return sorted(by: sortingOrder)
        } else {
            return self
        }
    }
}
