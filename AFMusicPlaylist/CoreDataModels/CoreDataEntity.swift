

import CoreData

typealias UpdatableCoreDataEntity = UpdatableEntity & NSMAnagedObject

protocol UpdatableEntity: class {
    static var globalName: String { get }
}
