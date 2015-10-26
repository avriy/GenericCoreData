//
//  CoreDataRepresentable.swift
//  GenericCoreData
//
//  Created by Artemiy Sobolev on 26.10.15.
//  Copyright © 2015 mipt. All rights reserved.
//

import Foundation

public
protocol CoreDataRepresentable: NSObjectProtocol {
    static var entityName: String { get }
}

