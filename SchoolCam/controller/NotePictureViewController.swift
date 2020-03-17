//
//  NotePictureViewController.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 10/03/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import UIKit

class NotePictureViewController: UIViewController {
	// MARK: - Outlet variables
	@IBOutlet weak var imageScrollView: UIScrollView!
	@IBOutlet weak var pictureImageView: UIImageView!
	
	// MARK: - Constraints outlets
	@IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
	
	// Class variables
	var note: ClassNote?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = note?.title
		pictureImageView.image = UIImage(data: note!.picture!)
		imageScrollView.delegate = self
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		updateMinZoomScaleForSize(imageScrollView.bounds.size)
	}
	
	// MARK: - IBActions
	@IBAction func doubleTapGesture(_ sender: UITapGestureRecognizer) {
		if imageScrollView.zoomScale == imageScrollView.minimumZoomScale {
			imageScrollView.zoom(to: zoomRectangle(scale: imageScrollView.maximumZoomScale, center: sender.location(in: sender.view)), animated: true)
		} else {
			imageScrollView.setZoomScale(imageScrollView.minimumZoomScale, animated: true)
		}
	}
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let items = [note!.picture]
        let activityViewController = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
}

// MARK: - Picture management
extension NotePictureViewController {
	private func updateMinZoomScaleForSize(_ size: CGSize) {
		let imageSize: CGSize = pictureImageView.image!.size
		let widthScale = size.width / imageSize.width
		let heightScale = size.height / imageSize.height
		let minScale = min(widthScale, heightScale)
		
		// Scale the image down to fit in the view
		imageScrollView.minimumZoomScale = minScale
		imageScrollView.zoomScale = minScale
		
		updateConstraintsForSize(size)
	}
	
	private func zoomRectangle(scale: CGFloat, center: CGPoint) -> CGRect {
		var zoomRect = CGRect.zero
		zoomRect.size.height = pictureImageView.frame.size.height / scale
		zoomRect.size.width  = pictureImageView.frame.size.width  / scale
		zoomRect.origin.x = center.x - (center.x * imageScrollView.zoomScale)
		zoomRect.origin.y = center.y - (center.y * imageScrollView.zoomScale)
		
		return zoomRect
	}
	
	func updateConstraintsForSize(_ size: CGSize) {
		let yOffset = max(0, (size.height - pictureImageView.frame.height) / 2)
		imageViewTopConstraint.constant = yOffset
		imageViewBottomConstraint.constant = yOffset
		
		let xOffset = max(0, (size.width - pictureImageView.frame.width) / 2)
		imageViewLeadingConstraint.constant = xOffset
		imageViewTrailingConstraint.constant = xOffset
		
		view.layoutIfNeeded()
	}
}

// MARK: - ScrollViewDelegate
extension NotePictureViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return pictureImageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		updateConstraintsForSize(imageScrollView.bounds.size)
	}
}
