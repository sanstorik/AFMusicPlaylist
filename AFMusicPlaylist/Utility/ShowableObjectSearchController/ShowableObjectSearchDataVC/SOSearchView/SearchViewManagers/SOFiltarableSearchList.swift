

import UIKit


protocol SOFilterableSearchList: class {
    associatedtype Element
    var filters: [SearchFilterPosition<Element>] { get }
}


extension SOFilterableSearchList {
    func searchListApplyFilters(_ list: [Element]) -> [Element] {
        return list.apply(filters: filters)
    }
}
