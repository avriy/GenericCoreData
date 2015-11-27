//
//  FetchedListViewModel.swift
//  CMProject
//
//  Created by nastia on 24/10/15.
//  Copyright © 2015 com.mipt. All rights reserved.
//

import UIKit
import CoreData

public
class FetchedListViewModel<T: CoreDataRepresentable, ConfigType: CoreDataConfig>: NSObject, NSFetchedResultsControllerDelegate {

	let tableView: UITableView
	public let fetchedResultsController: NSFetchedResultsController
	let coreDataManager = CoreDataManager<ConfigType>()
    public init(tableView: UITableView, predicate: NSPredicate? = nil, sortDescriptors sd: [NSSortDescriptor], sectionNameKeyPath snkp: String? = nil, cacheType: FetchResultsControllerCacheType) {
		self.tableView = tableView
		self.fetchedResultsController = coreDataManager.fetchResultsController(T.entityName, predicate: predicate, sortDiscriptors: sd, cacheName: cacheType.cache, sectionNameKeyPath:  snkp)
		super.init()
		self.fetchedResultsController.delegate = self
    }
    
    public func performFetch(errorHandler eh: ErrorHandler = ConsoleErrorHandler) {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
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
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
		case .Delete:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
		case .Update:
			tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
		case .Move:
			tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
		}
	}
	
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let sectionIndexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case .Insert:
            tableView.insertSections(sectionIndexSet, withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadSections(sectionIndexSet, withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(sectionIndexSet, withRowAnimation: .Automatic)
        case .Move:
            assertionFailure("not handled case")
        }
    }
    
	public func controllerWillChangeContent(controller: NSFetchedResultsController) {
		tableView.beginUpdates()
	}
	
	public func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.endUpdates()
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
