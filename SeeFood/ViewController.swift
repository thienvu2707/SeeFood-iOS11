//
//  ViewController.swift
//  SeeFood
//
//  Created by Thien Vu Le on Jun/24/18.
//  Copyright © 2018 Thien Vu Le. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var logoImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userTakedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            logoImageView.image = userTakedImage
            
            guard let ciImage = CIImage(image: userTakedImage) else {
                fatalError("Could not convert image ")
            }
            
            detect(image: ciImage)
        }
        
        //dismiss UI image picker
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("**** Error with loading CoreML Model *****")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "It is a Hotdog"
                } else {
                    self.navigationItem.title = "Not a Hotdog"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("***** Error handler ciImage \(error) *****")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
}

