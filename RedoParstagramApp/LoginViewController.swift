//
//  LoginViewController.swift
//  RedoParstagramApp
//
//  Created by Nelson  on 11/15/23.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginPress(_ sender: UIButton) {
        PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!) {
          (user: PFUser?, error: Error?) -> Void in
          if user != nil {
            // Do stuff after successful login.
              self.performSegue(withIdentifier: "loginToMainFeedSegue", sender: nil)
          } else {
            // The login failed. Check error to see why.
              if let error = error{
                  print("Error with login process: \(error.localizedDescription)")
              }
          }
        }
    }
    
    @IBAction func signupPress(_ sender: UIButton) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                let errorString = error.localizedDescription
                print("Error with sign up process try again \(errorString)")
            } else {
              // Hooray! Let them use the app now.
                self.performSegue(withIdentifier: "loginToMainFeedSegue", sender: nil)
                print("Welcome \(user.username ?? "user")")
                
            }
          }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
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
