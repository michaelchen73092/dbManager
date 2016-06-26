//
//  Persons+CoreDataProperties.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/23/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Persons {

    @NSManaged var birthday: NSDate?
    @NSManaged var isdoctor: NSNumber?
    @NSManaged var email: String?
    @NSManaged var firstname: String?
    @NSManaged var gender: String?
    @NSManaged var lastname: String?
    @NSManaged var password: String?

}
