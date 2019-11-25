

import Foundation
import RealmSwift


enum OperationResult {
    case performed, notNeeded, error(Error)
}


class DBUtility {
    static let shared = DBUtility()
    
    let realm = try? Realm()
    
    private init() { }
    
    func fetch<T: UpdatableDatabaseEntity>() -> Results<T>? {
        return realm?.objects(T.self)
    }
    
    func fetchObjects<T: UpdatableDatabaseEntity>() -> [T] {
        let results: Results<T>? = fetch()
        return results?.map { $0.self } ?? []
    }
}
