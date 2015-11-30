//
//  ErrorHandling.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 26.10.15.
//  Copyright (c) 2004-2015. Parallels IP Holdings GmbH. All rights reserved.
//  http://www.parallels.com
//

import Foundation

public
typealias ErrorHandler = NSError -> Void

public
let ConsoleErrorHandler: ErrorHandler = { error in
    print("Error happened: \(error)")
}

public
extension NSError {
    class func failedToOpenStore() -> NSError {
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
        let failureReason = "There was an error creating or loading the application's saved data."
        dict[NSLocalizedFailureReasonErrorKey] = failureReason
        let error = NSError(domain: "GenericCoreData", code: 1, userInfo: dict)
        dict[NSUnderlyingErrorKey] = error
        return error
    }
}
