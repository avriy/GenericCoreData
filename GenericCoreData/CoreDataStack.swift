//
//  CoreDataStack.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 26.10.15.
//  Copyright © 2015 mipt. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataEntityManagerContextType {
    case Main
}

class CoreDataManager {
    private static let coreDataManager = CoreDataPrivateManager()
    private let moc: NSManagedObjectContext
    init(contextType: CoreDataEntityManagerContextType = .Main) {
        self.moc = CoreDataManager.coreDataManager.managedObjectContext!
    }
    //  TODO: get rid of ConsoleErrorHandler here
    func save(errorHandler er: ErrorHandler = ConsoleErrorHandler) {
        CoreDataManager.coreDataManager.saveContext(errorHandler: er)
    }
}


extension CoreDataManager {
    func removeObject<T: CoreDataRepresentable>(object: T, errorHandler eh: ErrorHandler = ConsoleErrorHandler) {
        moc.deleteObject(object as! NSManagedObject)
        save(errorHandler: eh)
    }
    
    func createNewCoreDataRepresentable<T: CoreDataRepresentable>() -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(T.entityName, inManagedObjectContext: self.moc) as! T
    }
    
    func allRecords<T: CoreDataRepresentable>(predicate: NSPredicate? = nil, errorHandler: NSError -> Void) -> [T] {
        let fetchRequest = NSFetchRequest(entityName: T.entityName)
        fetchRequest.predicate = predicate
        do {
            return try self.moc.executeFetchRequest(fetchRequest) as! [T]
        } catch let error as NSError {
            errorHandler(error)
            return []
        }
    }
    
    func fetchResultsController(entityName: String, predicate: NSPredicate?, sortDiscriptors: [NSSortDescriptor]?, cacheName: String?, sectionNameKeyPath: String? = nil) -> NSFetchedResultsController {
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDiscriptors
        let fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        return fetchResultsController
    }
}

public
protocol CoreDataConfigurationProtocol {
    func modelURL() -> NSURL
    func configurateStoreCoordinator(coordinator: NSPersistentStoreCoordinator) throws
}


//extension CoreDataConfigurationProtocol {
//    func modelURL() -> NSURL {
//       return NSBundle.mainBundle().URLForResource("NameForTheModel", withExtension: "momd")!
//    }
//    
//    func configurateStoreCoordinator(coordinator: NSPersistentStoreCoordinator) throws {
//        let applicationDocumentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
//        let url = applicationDocumentsDirectory.URLByAppendingPathComponent("NameForTheModel.sqlite")
//        do {
//            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
//        } catch {
//            throw NSError.failedToOpenStore()
//        }
//    }
//}

private
class CoreDataPrivateManager: NSObject, CoreDataConfigurationProtocol {
    lazy var applicationDocumentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: self.modelURL())!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try self.configurateStoreCoordinator(coordinator)
            return coordinator
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext (errorHandler eh: ErrorHandler) {
        guard let moc = self.managedObjectContext else {
            return
        }
        if moc.hasChanges {
            do {
                try moc.save()
            } catch let error as NSError {
                eh(error)
                abort()
            }
        }
    }
}
