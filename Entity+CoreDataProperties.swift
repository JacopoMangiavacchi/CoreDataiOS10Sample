//
//  Entity+CoreDataProperties.swift
//  CoreDataiOS10Sample
//
//  Created by Jacopo Mangiavacchi on 10/31/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity");
    }

    @NSManaged public var attribute: String?

}
