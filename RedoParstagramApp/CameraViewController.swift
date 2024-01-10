//
//  CameraViewController.swift
//  RedoParstagramApp
//
//  Created by Nelson  on 11/17/23.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func submitBtnClick(_ sender: Any) {
        
        let post = PFObject(className: "Posts")
        post["user"] = PFUser.current()
        post["caption"] = commentField.text
        
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground{ (success, error) in
            if success{
                self.dismiss(animated: true)
                print("success")
            } else{
                print("error")
            }
            
        }
    }
    
    @IBAction func clickImage(_ sender: Any) {
        let picker =  UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing =  true
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .camera
        }
        
        present(picker, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        
        let scaledImage = image.af.imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
