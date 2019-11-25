

import RealmSwift

typealias UpdatableDatabaseEntity = UpdatableEntity & Object

protocol UpdatableEntity: class {
    static var globalName: String { get }
}
