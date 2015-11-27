//
//  CoreDataConfig.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 27.10.15.
//  Copyright © 2015 com.parallels. All rights reserved.
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
