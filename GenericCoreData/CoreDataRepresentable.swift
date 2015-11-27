//
//  CoreDataRepresentable.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 26.10.15.
//  Copyright © 2015 com.mipt. All rights reserved.
//

import Foundation
import CoreData

public
protocol CoreDataRepresentable: NSObjectProtocol {
    static var entityName: String { get }
    static func fetchRequest() -> NSFetchRequest
}

public
extension CoreDataRepresentable {
    static func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: self.entityName)
    }
}

