//
//  FetchedListViewModel.swift
//  CMProject
//
//  Created by Nastia Soboleva on 24/10/15.
//  Copyright (c) 2004-2015. Parallels IP Holdings GmbH. All rights reserved.
//  http://www.parallels.com
//

import CoreData

public
struct CollectionViewReloadHandlers {
    let insertItemsAtIndexPaths: [NSIndexPath] -> Void
    let deleteItemsAtIndexPaths: [NSIndexPath] -> Void
    let updateItemsAtIndexPaths: [NSIndexPath] -> Void
    
    let insertSection: Int -> Void
    let deleteSection: Int -> Void
    let updateSection: Int -> Void
    
    let update: Void -> Void
    let willStartUpdates: Void -> Void
    let didEndUpdates: Void -> Void
}

public
class FetchedListController<T: CoreDataRepresentable, ConfigType: CoreDataConfig>: NSObject, NSFetchedResultsControllerDelegate {

	public let fetchedResultsController: NSFetchedResultsController
	let coreDataManager = CoreDataManager<ConfigType>()
    let reloadHandlers: CollectionViewReloadHandlers
    public init(reloadHandlers: CollectionViewReloadHandlers, predicate: NSPredicate? = nil, sortDescriptors sd: [NSSortDescriptor], sectionNameKeyPath snkp: String? = nil, cacheType: FetchResultsControllerCacheType) {
		self.reloadHandlers = reloadHandlers
		self.fetchedResultsController = coreDataManager.fetchResultsController(T.entityName, predicate: predicate, sortDiscriptors: sd, cacheName: cacheType.cache, sectionNameKeyPath:  snkp)
		super.init()
		self.fetchedResultsController.delegate = self
    }
    
    public func performFetch(errorHandler eh: ErrorHandler = ConsoleErrorHandler) {
        do {
            try fetchedResultsController.performFetch()
            reloadHandlers.update()
        } catch let error as NSError {
            eh(error)
        }
    }
	
    public func item(indexPath: NSIndexPath) -> T? {
        return fetchedResultsController.objectAtIndexPath(indexPath) as? T
    }
    
    public func removeItem(indexPath: NSIndexPath) {
        guard let item = item(indexPath) else {
            return
        }
        coreDataManager.removeObject(item)
    }
    
	public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case .Insert:
            reloadHandlers.insertItemsAtIndexPaths([newIndexPath!])
		case .Delete:
            reloadHandlers.deleteItemsAtIndexPaths([indexPath!])
		case .Update:
            reloadHandlers.updateItemsAtIndexPaths([indexPath!])
		case .Move:
            reloadHandlers.deleteItemsAtIndexPaths([indexPath!])
            reloadHandlers.insertItemsAtIndexPaths([newIndexPath!])
		}
	}
	
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            reloadHandlers.insertSection(sectionIndex)
        case .Update:
            reloadHandlers.updateSection(sectionIndex)
        case .Delete:
            reloadHandlers.deleteSection(sectionIndex)
        case .Move:
            assertionFailure("not handled case")
        }
    }
    
	public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        reloadHandlers.willStartUpdates()
    }
	
	public func controllerDidChangeContent(controller: NSFetchedResultsController) {
		reloadHandlers.didEndUpdates()
	}
}

public
enum FetchResultsControllerCacheType {
	case NoCache, SpesificCache(String), RandomCache
	
	var cache: String? {
		switch self {
		case .SpesificCache(let name):
			return name
		case .RandomCache:
			return NSUUID().UUIDString
		case .NoCache:
			return nil
		}
	}
}
