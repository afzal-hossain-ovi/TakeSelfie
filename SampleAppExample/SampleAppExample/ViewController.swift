//
//  ViewController.swift
//  SampleAppExample
//
//  Created by Afzal Hossain on 09.06.21.
//

import UIKit
import TakeSelfie

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    @IBAction func takeSelfieBtnTapped(_ sender: Any) {
        
        imageView.image = nil
        
        let selfieVC = TakeSelfieViewController()
        present(selfieVC, animated: true)
        
        selfieVC.captureImage = { image in
            if let _image = image {
                DispatchQueue.main.async {
                    selfieVC.dismiss(animated: true) {
                    let alert = UIAlertController(title: "Saved", message: "Your selfie successfully saved to library.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                        
                            self.imageView.image = _image
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
            }else {
                print("Couldn't save selfie to library.")
            }
        }
    }
}

