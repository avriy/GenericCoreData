//
//  CoreDataRepresentable.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 26.10.15.
//  Copyright (c) 2004-2015. Parallels IP Holdings GmbH. All rights reserved.
//  http://www.parallels.com
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

