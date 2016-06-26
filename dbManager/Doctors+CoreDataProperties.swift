//
//  Doctors+CoreDataProperties.swift
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

extension Doctors {

    @NSManaged var doctorGraduateSchool: String?
    @NSManaged var doctorProfession: String?
    @NSManaged var doctorLanguage: NSObject?
    @NSManaged var doctorHospital: String?
    @NSManaged var doctorOneStarNumber: NSNumber?
    @NSManaged var doctorTwoStarNumber: NSNumber?
    @NSManaged var doctorThreeStarNumber: NSNumber?
    @NSManaged var doctorFourStarNumber: NSNumber?
    @NSManaged var doctorFiveStarNumber: NSNumber?
    @NSManaged var doctorStar: NSNumber?

}
