//
//  CoreDataConfig.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 27.10.15.
//  Copyright (c) 2004-2015. Parallels IP Holdings GmbH. All rights reserved.
//  http://www.parallels.com
//

import Foundation
import CoreData

public
protocol CoreDataConfig {
    static func configurationName() -> String
    static func modelURL() -> NSURL
    static func configurateStoreCoordinator(coordinator: NSPersistentStoreCoordinator) throws
}

//    Example CoreDataConfig:
//class AppConfig: CoreDataConfig {
//    static func configurationName() -> String {
//        return "AppConfig"
//    }
//    
//    class func modelURL() -> NSURL {
//        return NSBundle.mainBundle().URLForResource("TestCoreData", withExtension: "momd")!
//    }
//    
//    class func configurateStoreCoordinator(coordinator: NSPersistentStoreCoordinator) throws {
//        let applicationDocumentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
//        let url = applicationDocumentsDirectory.URLByAppendingPathComponent("TestCoreData.sqlite")
//        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
//    }
//}
