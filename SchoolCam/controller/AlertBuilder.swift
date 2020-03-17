//
//  AlertBuilder.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 08/03/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import UIKit

class AlertBuilder {
	static func getMessageAlert(_ title: String, _ message: String) -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "Listo", style: .default)
		alert.addAction(action)
		return alert
	}
	static func getTextFieldAlert(title: String, message: String, placeholder: String, autoCapitalization: UITextAutocapitalizationType = .words, autoCorrection: UITextAutocorrectionType = .yes, successFunc: ((String) -> Void)?, cancelFunc: (()->Void)?) -> UIAlertController {
		var alertTextField: UITextField?
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
			cancelFunc?()
		}
		let addAction = UIAlertAction(title: "Listo", style: .default) { (action) in
			let text = alertTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
			successFunc?(text)
		}
		alert.addTextField { (textField) in
			textField.placeholder = placeholder
			textField.autocapitalizationType = autoCapitalization
			textField.autocorrectionType = autoCorrection
			alertTextField = textField
		}
		alert.addAction(cancelAction)
		alert.addAction(addAction)
		return alert
	}
}
