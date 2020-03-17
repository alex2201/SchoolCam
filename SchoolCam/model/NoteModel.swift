//
//  NoteModel.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 07/03/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData

class NoteModel: ManagedObjectModel {
	var schoolClass: SchoolClass
	var notes = [ClassNote]()
	
	init(with context: NSManagedObjectContext, for schoolClass: SchoolClass) {
		self.schoolClass = schoolClass
		super.init(with: context)
	}
	
	func loadNotes() {
		notes = (schoolClass.notes?.allObjects as! [ClassNote])
		notes = notes.sorted(by: {$0.taken! > $1.taken!})
	}
	
	func createNote(for schoolClass: SchoolClass, withPhoto photo: Data, withTitle title: String) {
		let notePhoto = ClassNote(context: context)
		notePhoto.title = title.count > 0 ? title : "Sin título"
		notePhoto.picture = photo
		notePhoto.taken = Date()
        notePhoto.schoolClass = schoolClass
		saveContext()
	}
	
	func deleteNote(_ note: ClassNote) {
		context.delete(note)
		saveContext()
	}
	
	func deleteNote(at index: Int) {
		context.delete(notes[index])
		notes.remove(at: index)
		saveContext()
	}
}
