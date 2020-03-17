//
//  CameraViewController.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 27/02/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
	// MARK: - Outlet variables
	@IBOutlet weak var cameraPreviewView: PreviewView!
    @IBOutlet weak var picturePreviewImageView: UIImageView!
    
	// MARK: - Class variables
	private var orientation: UIDeviceOrientation?
	private let session = AVCaptureSession()
	private var photoOutput: AVCapturePhotoOutput?
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	private var notesModel: NoteModel?
    private var schoolClassModel: SchoolClassModel?
	var selectedClass: SchoolClass?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set custom UI elements
        navigationItem.title = selectedClass?.name
		
		// Init models
        schoolClassModel = SchoolClassModel(with: context)
		notesModel = NoteModel(with: context, for: selectedClass!)
		
		prepareCamera()
	}
	
	override func viewWillLayoutSubviews() {
		orientation = UIDevice.current.orientation

		switch (orientation) {
		case .portrait:
			cameraPreviewView.videoPreviewLayer.connection!.videoOrientation = .portrait
		case .landscapeRight:
			cameraPreviewView.videoPreviewLayer.connection!.videoOrientation = .landscapeLeft
		case .landscapeLeft:
			cameraPreviewView.videoPreviewLayer.connection!.videoOrientation = .landscapeRight
		default:
			cameraPreviewView.videoPreviewLayer.connection!.videoOrientation = .portrait
		}
	}
	
	@IBAction func takePhotoButtonPressed(_ sender: UIBarButtonItem) {
		takePhoto()
	}
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
}

// MARK: - Camera funtions
extension CameraViewController {
	func takePhoto() {
		let photoSettings = AVCapturePhotoSettings()
		photoSettings.flashMode = .off
		photoOutput!.capturePhoto(with: photoSettings, delegate: self)
	}
	
	private func requestCameraAccess() {
		AVCaptureDevice.requestAccess(for: .video, completionHandler: {granted in
			if granted {
				self.setupCaptureSession()
			} else {
				self.handleDeniedCameraAccess()
			}
		})
	}
	
	private func prepareCamera(){
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			setupCaptureSession()
		case .notDetermined:
			requestCameraAccess()
		case .denied, .restricted:
			handleDeniedCameraAccess()
		@unknown default:
			fatalError("Unknown authorization status.")
		}
	}
	
	private func handleDeniedCameraAccess(){
		print("Camera access denied.")
	}
	
	private func setupCaptureSession(){
		// Setup input.
		if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			session.beginConfiguration()
			guard
				let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
				session.canAddInput(videoDeviceInput)
				else { return }
			session.addInput(videoDeviceInput)
			
			// Setup output.
			photoOutput = AVCapturePhotoOutput()
			photoOutput!.isHighResolutionCaptureEnabled = true
			guard session.canAddOutput(photoOutput!) else { return }
			session.sessionPreset = .photo
			session.addOutput(photoOutput!)
			session.commitConfiguration()
			
			// Setup preview view.
			cameraPreviewView.videoPreviewLayer.session = session
			
			session.startRunning()
		}
	}
	
	private func handlePhotoOutput(forPhoto photo: UIImage) {
        let alert = AlertBuilder.getTextFieldAlert(
            title: "Nueva nota",
            message: "Título de la nota",
            placeholder: "Título",
            autoCapitalization: .words,
            autoCorrection: .yes,
            successFunc: {(text) in
                self.notesModel?.createNote(for: self.selectedClass!, withPhoto: photo.jpegData(compressionQuality: 1.0)!, withTitle: text)
                let alert = AlertBuilder.getMessageAlert("Listo", "!La nota se ha guardado correctamente! 😃")
                self.cameraPreviewView.isHidden = false
                self.picturePreviewImageView.image = nil
                self.picturePreviewImageView.isHidden = true
                self.present(alert, animated: true, completion: nil)},
            cancelFunc: {() in
                self.cameraPreviewView.isHidden = false
                self.picturePreviewImageView.image = nil
                self.picturePreviewImageView.isHidden = true
        })
        cameraPreviewView.isHidden = true
        picturePreviewImageView.image = photo
        picturePreviewImageView.isHidden = false
        present(alert, animated: true, completion: nil)
    }
	
	func getUIImageOrientationFromDevice() -> UIImage.Orientation {
		// return CGImagePropertyOrientation based on Device Orientation
		// This extented function has been determined based on experimentation with how an UIImage gets displayed.
		switch orientation {
		case .portrait, .faceUp: return UIImage.Orientation.right
		case .portraitUpsideDown, .faceDown: return UIImage.Orientation.left
		case .landscapeLeft: return UIImage.Orientation.up // this is the base orientation
		case .landscapeRight: return UIImage.Orientation.down
		default: return UIImage.Orientation.up
		}
	}
}

// MARK: - Photo Capture Delegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let imageData = photo.fileDataRepresentation() else {
			print("Error retrieving image data")
			return
		}
		guard let uiImage = UIImage(data: imageData) else {
			print("Error retrieving uiimage")
			return
		}
		guard let cgImage = uiImage.cgImage else {
			print("Error retrieving cgimage")
			return
		}
        let photoTemp = UIImage(cgImage: cgImage, scale: 1.0, orientation: getUIImageOrientationFromDevice())     
        handlePhotoOutput(forPhoto: photoTemp)
	}
}
