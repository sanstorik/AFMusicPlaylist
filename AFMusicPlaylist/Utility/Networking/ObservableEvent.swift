

import UIKit


fileprivate struct RetainFreeObserverHolder<T: AnyObject & Hashable>: Hashable, Equatable {
    private(set) weak var observer: T?
    
    
    init(for object: T) {
        self.observer = object
    }
    
    
    static func ==(lhs: RetainFreeObserverHolder, rhs: RetainFreeObserverHolder) -> Bool {
        return lhs.observer == rhs.observer
    }
    
    
    func hash(into hasher: inout Hasher) {
        if let _vc = observer {
            hasher.combine(_vc)
        } else {
            hasher.combine(0)
        }
    }
}


class ObservableValueEvent<T: Hashable, T1> {
    private var observers = [T: [(T1) -> Void]]()
    
    
    func addObserver(_ observer: T, _ action: @escaping (T1) -> Void) {
        if observers[observer] == nil {
            observers[observer] = []
        }
        observers[observer]?.append(action)
    }
    
    
    func removeObserver(_ observer: T) {
        self.observers.removeValue(forKey: observer)
    }
    
    
    func notifyObservers(_ value: T1) {
        for observer in observers.values {
            for observerCallback in observer {
                observerCallback(value)
            }
        }
    }
}



class AFImageDownloadEvent: ObservableValueEvent<String, UIImage?> { }
