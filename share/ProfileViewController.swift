//
//  ProfileViewController.swift
//  share
//
//  Created by Tyler Powell on 5/2/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
        title = "Profile"
        self.navigationItem.setHidesBackButton(true, animated: false)
        print(Auth.auth().currentUser!)
        // Do any additional setup after loading the view.
    }
    
    private func validateAuth(){
        guard let vc = (storyboard?.instantiateViewController(identifier: "login") as? LoginViewController)else {
            print("failed to get vc from storyboard")
            return
        }
        if Auth.auth().currentUser == nil{
            self.show(vc, sender: self)
        }
    }
    
    @IBAction func logout_user(_ sender: Any) {
        let firebaseAuth = Auth.auth()
       do {
        print(firebaseAuth.currentUser)
         try firebaseAuth.signOut()
        print(firebaseAuth.currentUser)
       } catch let signOutError as NSError {
         print ("Error signing out: %@", signOutError)
       }
        validateAuth()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        if(Auth.auth().currentUser != nil){
            print(Auth.auth().currentUser!)
            DatabaseManager.shared.getUser(with: Auth.auth().currentUser!.uid, completion:{newUser in
                self.email.text = newUser.emailAddress
                self.name.text = "\(newUser.firstName) \(newUser.lastName)"
            })
        }
    }
}
