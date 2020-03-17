//
//  NotesTableViewController.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 06/03/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {
	// MARK: - Outlet variables
	@IBOutlet weak var addButton: UIBarButtonItem!
	
	// MARK: - Class variables
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	var selectedClass: SchoolClass?
	private var notesModel: NoteModel?
	var selectedNote: ClassNote?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set custom UI components
		navigationItem.title = selectedClass?.name
		
		// Init models
		notesModel = NoteModel(with: context, for: selectedClass!)
		notesModel?.loadNotes()
		self.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems! +  [self.editButtonItem]
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		addButton.isEnabled = !editing
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		notesModel?.loadNotes()
		tableView.reloadData()
	}
	
	@IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "goToCamera", sender: self)
	}
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case "goToCamera":
			let destination = segue.destination as! CameraViewController
			destination.selectedClass = selectedClass
		case "goToNoteDetail":
			let destination = segue.destination as! NotePictureViewController
			if let note = selectedNote {
				destination.note = note
			}
		default: break
		}
	}
}

// MARK: - Table View Delegate
extension NotesTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedNote = notesModel!.notes[indexPath.row]
		performSegue(withIdentifier: "goToNoteDetail", sender: self)
	}
}

// MARK: - Table View DataSource
extension NotesTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return notesModel!.notes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteTableViewCell
		let note = notesModel!.notes[indexPath.row]
		if let data = note.picture {
			cell.picture.image = loadScaledImage(for: data, into: cell.picture.bounds)
			let df = DateFormatter()
			df.dateFormat = "dd-MM-yyyy"
			cell.dateLabel.text = df.string(from: note.taken!)
			df.dateFormat = "hh:mm"
			cell.timeLabel.text = df.string(from: note.taken!)
			cell.titleLabel.text = note.title
		} else {
			cell.imageView?.image = UIImage(systemName: "photo")
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			notesModel?.deleteNote(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
}

// MARK: - Load scaled image
extension NotesTableViewController {
	func loadScaledImage(for data: Data, into rect: CGRect) -> UIImage? {
		let minBound = min(rect.size.height, rect.size.width)
		let image = UIImage(data: data)
		let imageSize = image?.size
		let heighScale = minBound / imageSize!.height
		let widthScale = minBound / imageSize!.width
		let scale = min(heighScale, widthScale)
		return resizedImage(image!, for: CGSize(width: imageSize!.width * scale, height: imageSize!.height * scale))
	}
	
	// TODO: - Find optimization
	func resizedImage(_ image: UIImage, for size: CGSize) -> UIImage? {
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { (context) in
			image.draw(in: CGRect(origin: .zero, size: size))
		}
	}
}
