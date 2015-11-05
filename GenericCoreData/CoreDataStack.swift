//
//  CoreDataStack.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 26.10.15.
//  Copyright © 2015 mipt. All rights reserved.
//

import Foundation
import CoreData

public 
enum CoreDataEntityManagerContextType: String {
    case Main, PrivateQueue
}

private
class ManagersController {
    static let managersController = ManagersController()
    var managers = [String : AnyObject]()
    func coreDataManager<T: CoreDataConfig>(contextType: CoreDataEntityManagerContextType) -> CoreDataPrivateStack<T> {
        let managerID = T.configurationName()
        if let manager = self.managers[managerID] as? CoreDataPrivateStack<T> {
            return manager
        } else {
            let newManager: CoreDataPrivateStack<T> = CoreDataPrivateStack()
            self.managers[managerID] = newManager
            return newManager
        }
    }
}

public
class CoreDataManager<T: CoreDataConfig> {

    private var coreDataPrivateManager: CoreDataPrivateStack<T> {
        return ManagersController.managersController.coreDataManager(self.contextType)
    }
    
    private lazy var privateObjectContext: NSManagedObjectContext = {
        return self.coreDataPrivateManager.privateManagedObjectContext!
    }()
    
    private var moc: NSManagedObjectContext {
        switch self.contextType {
        case .Main:
            return self.coreDataPrivateManager.managedObjectContext!
        case .PrivateQueue:
            return self.privateObjectContext
        }
    }
    private let contextType: CoreDataEntityManagerContextType
    public init(contextType: CoreDataEntityManagerContextType = .Main) {
        self.contextType = contextType
    }
    //  TODO: get rid of ConsoleErrorHandler here
    public func save(errorHandler er: ErrorHandler = ConsoleErrorHandler) {
        coreDataPrivateManager.saveContext(errorHandler: er)
    }
}

public
extension CoreDataManager {
    func removeObject<T: CoreDataRepresentable>(object: T, errorHandler eh: ErrorHandler = ConsoleErrorHandler) {
        moc.deleteObject(object as! NSManagedObject)
        save(errorHandler: eh)
    }
    
    func execute(block: Void -> Void) {
        self.moc.performBlock(block)
    }
    
    func createNewCoreDataRepresentable<T: CoreDataRepresentable>() -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(T.entityName, inManagedObjectContext: self.moc) as! T
    }
    
    func allRecords<T: CoreDataRepresentable>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, errorHandler: NSError -> Void) -> [T] {
        let fetchRequest = NSFetchRequest(entityName: T.entityName)
        fetchRequest.predicate = predicate
        do {
            return try self.moc.executeFetchRequest(fetchRequest) as! [T]
        } catch let error as NSError {
            errorHandler(error)
            return []
        }
    }
    
    func executeAsyncRequest<T: CoreDataRepresentable>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, errorHandler: NSError -> Void, completion: [T] -> Void) {
        assert(self.contextType == .PrivateQueue, "")
        let fetchRequest = NSFetchRequest(entityName: T.entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (fetchResult) -> Void in
            if let result = fetchResult.finalResult as? [T] {
                completion(result)
            } else {
                completion([])
            }
        }
        assert(self.privateObjectContext == self.privateObjectContext)
        self.privateObjectContext.performBlock {
            do {
                try self.privateObjectContext.executeRequest(asyncRequest)
            } catch let error as NSError {
                errorHandler(error)
            }
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

private
class CoreDataPrivateStack<T: CoreDataConfig>: NSObject {
    lazy var applicationDocumentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: T.modelURL())!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try T.configurateStoreCoordinator(coordinator)
            return coordinator
        } catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }()
    
    var privateManagedObjectContext: NSManagedObjectContext? {
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.persistentStoreCoordinator = coordinator
//        managedObjectContext.parentContext = self.managedObjectContext
        return moc
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = coordinator
        return moc
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
