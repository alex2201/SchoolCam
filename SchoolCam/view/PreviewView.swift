//
//  PreviewView.swift
//  SchoolCam
//
//  Created by Alexander Lopez Cedillo on 27/02/20.
//  Copyright © 2020 Alexander Lopez Cedillo. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
	override class var layerClass: AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
	
	/// Convenience wrapper to get layer as its statically known type.
	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
		return layer as! AVCaptureVideoPreviewLayer
	}
}
