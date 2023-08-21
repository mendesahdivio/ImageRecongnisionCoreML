//
//  ViewController.swift
//  SeeFood-CoreML
//
//  Created by Angela Yu on 27/06/2017.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var imageView: UIImageView!
  var classificationResults : [VNClassificationObservation] = []
  let imagePicker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imagePicker.delegate = self
    
  }
  
  func detect(image: CIImage) {
    
    
    // Load the ML model through its generated class
    let config = MLModelConfiguration()
    guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: config).model) else {
      fatalError("can't load ML model")
    }
    
    let request = VNCoreMLRequest(model: model) {[weak self] request, error in
      guard let results = request.results as? [VNClassificationObservation],
            let topResult = results.first
      else {
        fatalError("unexpected result type from VNCoreMLRequest")
      }
      
      //set result to the nav bar
      self?.setResult(identifiedObject: topResult.identifier)
    }
    
    let handler = VNImageRequestHandler(ciImage: image)
    
    do {
      try handler.perform([request])
    }
    catch {
      print(error)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    if let image = info[.originalImage] as? UIImage {
      
      imageView.image = image
      imageView.contentMode = .scaleAspectFit
      imagePicker.dismiss(animated: true, completion: nil)
      guard let ciImage = CIImage(image: image) else {
        fatalError("couldn't convert uiimage to CIImage")
      }
      detect(image: ciImage)
    }
  }
  
  
  @IBAction func cameraTapped(_ sender: Any) {
    
    imagePicker.sourceType = .photoLibrary
    imagePicker.allowsEditing = false
    present(imagePicker, animated: true, completion: nil)
  }
  
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
  return input.rawValue
}



extension ViewController {
  final func setResult(identifiedObject: String) {
    DispatchQueue.main.async {[weak self] in
      self?.navigationItem.title = identifiedObject
      self?.navigationController?.navigationBar.barTintColor = UIColor.green
      self?.navigationController?.navigationBar.isTranslucent = false
    }
  }
}
