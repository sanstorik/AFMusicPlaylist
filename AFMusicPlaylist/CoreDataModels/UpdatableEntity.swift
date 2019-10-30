

import CoreData

typealias UpdatableCoreDataEntity = UpdatableEntity & NSManagedObject

protocol UpdatableEntity: class {
    static var globalName: String { get }
}
