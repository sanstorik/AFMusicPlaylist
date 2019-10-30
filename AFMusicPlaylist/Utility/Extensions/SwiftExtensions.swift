
import Foundation


extension Optional {
    func none<T>(_ none: @autoclosure () -> T, _ some: (Wrapped) -> T) -> T {
        switch self {
        case .some(let object):
            return some(object)
        case .none:
            return none()
        }
    }
    
    
    func some<T>( _ handle: (() -> Void)? = nil, _ some: (Wrapped) -> T?) -> T? {
        switch self {
        case .some(let object):
            return some(object)
        case .none:
            handle?()
            return nil
        }
    }
}


infix operator ??!
func ??! <T>(_ optional: T?, defaultValue: @autoclosure () -> T) -> T {
    switch optional {
    case .some(let value):
        return value
    case .none:
        return defaultValue()
    }
}
