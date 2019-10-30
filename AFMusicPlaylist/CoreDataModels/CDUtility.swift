

import Foundation
import CoreData


enum OperationResult {
    case performed, notNeeded, error(Error)
}


class CDUtility {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AFMusicPlaylist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    func fetch<T: NSManagedObject>(_ entityName: String, in context: NSManagedObjectContext) -> [T]? {
        return fetch(entityName: entityName, context: context)
    }
    
    
    func fetch<T: UpdatableCoreDataEntity>() -> [T]? {
        return fetch(entityName: T.globalName, context: context)
    }
    
    
    func fetch<T: NSFetchRequestResult>(entityName: String, context: NSManagedObjectContext,
                                        sort: [NSSortDescriptor]? = nil) -> [T] {
        let fetchRq = NSFetchRequest<T>(entityName: entityName)
        fetchRq.sortDescriptors = sort
        
        return (try? context.fetch(fetchRq)) ?? []
    }
}


extension NSManagedObjectContext {
    @discardableResult
    func saveContext() -> OperationResult {
        var result: OperationResult = .notNeeded
        if hasChanges {
            do {
                try save()
                result = .performed
            } catch let error {
                result = .error(error)
            }
        }
        
        return result
    }
}
