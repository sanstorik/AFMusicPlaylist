

import UIKit


protocol SearchHandlerDataSource: class {
    associatedtype Object
    func fetchOriginalList() -> [Object]
    func selectedRow(with object: Object)
}


class SearchDataSourceWrapper<T: UpdatableEntity> {
    private let listClosure: () -> [T]
    private let selectRowClosure: (T) -> Void
    
    
    init<S: SearchHandlerDataSource>(_ dataSource: S) where S.Object == T {
        self.listClosure = dataSource.fetchOriginalList
        self.selectRowClosure = dataSource.selectedRow
    }
    
    func fetchOriginalList() -> [T] {
        return listClosure()
    }
    
    
    func selectedRow(with object: T) {
        selectRowClosure(object)
    }
}
