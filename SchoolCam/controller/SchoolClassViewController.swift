//
//  ClassesViewController.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 02/03/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import UIKit
import CoreData

class SchoolClassViewController: UIViewController {
	// MARK: - Outlet variables
	@IBOutlet weak var schoolClassesTableView: UITableView!
	@IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
	// MARK: - Class variables
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	private var schoolClassModel: SchoolClassModel?
	private var selectedClass: SchoolClass?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set custom UI elements
		tableViewSetup()
		
		// Init models
		schoolClassModel = SchoolClassModel(with: context)
		schoolClassModel!.loadSchoolClasses()
	}
	
	// MARK: - ButtonBar Actions
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = AlertBuilder.getTextFieldAlert(
		title: "Nueva clase",
		message: "Nombre de la clase",
		placeholder: "Nombre",
		successFunc: { (text) in
			self.schoolClassModel!.addSchoolClass(named: text)
			self.schoolClassesTableView.reloadData()
		},
		cancelFunc: nil)
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
		switch sender.title {
		case "Edit":
			schoolClassesTableView.setEditing(true, animated: true)
			editButton.title = "Done"
			editButton.style = .done
            addButton.isEnabled = false
		case "Done":
			schoolClassesTableView.setEditing(false, animated: true)
			editButton.title = "Edit"
			editButton.style = .plain
            addButton.isEnabled = true
		default:
			break
		}
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goToNotes" {
			let destination = segue.destination as! NotesTableViewController
			destination.selectedClass = selectedClass
		}
	}
}

// MARK: - TableView Setup
extension SchoolClassViewController {
	
	func tableViewSetup() {
		schoolClassesTableView.delegate = self
		schoolClassesTableView.dataSource = self
		schoolClassesTableView.rowHeight = UITableView.automaticDimension
		schoolClassesTableView.estimatedRowHeight = 350
		
		// NOTE: - Registering the cell programmatically
		schoolClassesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "classCell")
	}
	
}

// MARK: - Table View Delegate
extension SchoolClassViewController: UITableViewDelegate{
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedClass = schoolClassModel!.classes[indexPath.row]
		performSegue(withIdentifier: "goToNotes", sender: self)
	}
}

//MARK: - TableView DataSource
extension SchoolClassViewController: UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return schoolClassModel!.classes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = schoolClassesTableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
		cell.textLabel?.text = schoolClassModel!.classes[indexPath.row].name
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			schoolClassModel!.removeSchoolClassFromArray(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		default:
			break
		}
	}
}
