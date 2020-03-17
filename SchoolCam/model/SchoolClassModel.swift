//
//  SchoolClassModel.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 03/03/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import Foundation
import CoreData

class SchoolClassModel: ManagedObjectModel {
	var classes = [SchoolClass]()
	
	func addSchoolClass(named name: String) {
        let newSchoolClass = SchoolClass(context: context)
        newSchoolClass.name = name
		classes.append(newSchoolClass)
		saveContext()
	}
	
	func removeSchoolClassFromArray(at index: Int) {
		context.delete(classes[index])
		classes.remove(at: index)
		saveContext()
	}
	
	func loadSchoolClasses() {
        let request: NSFetchRequest<SchoolClass> = SchoolClass.fetchRequest()
		classes = executeFetchRequest(for: request) as? [SchoolClass] ?? [SchoolClass]()
    }
}
