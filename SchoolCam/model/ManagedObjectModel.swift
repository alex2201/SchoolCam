//
//  ManagedObjectModel.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 07/03/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import Foundation
import CoreData

class ManagedObjectModel {
	var context: NSManagedObjectContext
	
	init(with context: NSManagedObjectContext) {
		self.context = context
	}
	
	func saveContext(){
		do{
			try context.save()
		} catch {
			print("Error saving context: ", error)
		}
	}
	
	func executeFetchRequest(for request: NSFetchRequest<SchoolClass>) -> [NSFetchRequestResult]?{
		var data: [NSFetchRequestResult]?
        do{
			data = try context.fetch(request)
        } catch {
            print("Error loading school classes: ", error)
        }
		return data
    }
}
