//
//  TableViewSupport.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 30.11.15.
//  Copyright © 2015 com.parallels. All rights reserved.
//

import UIKit

public
extension UITableView {
    var collectionViewReloadHandlers: CollectionViewReloadHandlers {
        let insertItems: [NSIndexPath] -> Void = { [weak self] indexPaths in
            self?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        }
        
        let deleteItems: [NSIndexPath] -> Void = { [weak self] indexPaths in
            self?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        }
        
        let updateItems: [NSIndexPath] -> Void = { [weak self] indexPaths in
            self?.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        }
        
        let insertSection: Int -> Void = { [weak self] sectionIndex in
            self?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        }
        let deleteSection: Int -> Void = { [weak self] sectionIndex in
            self?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        }
        let updateSection: Int -> Void = { [weak self] sectionIndex in
            self?.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        }
        
        let update: Void -> Void = { [weak self] _ in
            self?.reloadData()
        }
        
        let willStartUpdates: Void -> Void = { [weak self] in
            self?.beginUpdates()
        }
        let didEndUpdates: Void -> Void = { [weak self] in
            self?.endUpdates()
        }
        
        return CollectionViewReloadHandlers(insertItemsAtIndexPaths: insertItems,
            deleteItemsAtIndexPaths: deleteItems,
            updateItemsAtIndexPaths: updateItems,
            insertSection: insertSection,
            deleteSection:deleteSection,
            updateSection: updateSection,
            update: update,
            willStartUpdates: willStartUpdates,
            didEndUpdates: didEndUpdates)
    }
}
