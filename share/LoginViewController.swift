//
//  ViewController.swift
//  share
//
//  Created by Tyler Powell on 4/29/21.
//

import UIKit
import Firebase

var REGISTERED: Bool = false

class LoginViewController: UIViewController {

    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var message: UILabel!
    

    
    
    @IBAction func login(_ sender: Any) {
        guard let vc = (storyboard?.instantiateViewController(identifier: "collection") as? CollectionViewController)else {
            print("failed to get vc from storyboard")
            return
        }
        
        
        let emailInput2 = emailInput.text
        let passwordInput2 = passwordInput.text

        print("emailInput2: ",emailInput2!)
        if(emailInput2! != "" && passwordInput2! != ""){
            Auth.auth().signIn(withEmail: emailInput2!, password: passwordInput2!, completion: {authResult, error in
                guard let result = authResult, error == nil else{
                    print("Failed to log in user. \(String(describing: emailInput2))")
                    self.showToast(message: "Login unsuccessful. Check username and password.", seconds: 2.0)
                    return
                }
                let user = String(describing:  result.user)
                print("Logged in user: \(user)")
                self.show(vc, sender: self)

            })
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        self.navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.layer.zPosition = -0
    }
    
//    dismisses the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

class RegisterViewController: UIViewController{
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if let firstVC = presentingViewController as? LoginViewController {
                DispatchQueue.main.async {
                    firstVC.emailInput.text = self.email.text
                    firstVC.emailInput.text = self.password1.text
                    firstVC.login.sendActions(for: .touchUpInside)
                    firstVC.showToast(message: "Successfully created account...", seconds: 1.0)

                }
            }
    }
    
    @IBAction func register(_ sender: Any) {
//        TODO: Have to register the user here
        
        if(password1.text == password2.text && password1 != nil && password2 != nil && email != nil){
            Auth.auth().createUser(withEmail: email.text!, password: password1.text!) { authResult, error in
                guard let result = authResult, error == nil else{
                    print("Error creating user")
                    return
                }
                let user = result.user
                print("Created user: \(user)")
                let newUser = ShareUser(id: user.uid ,firstName: self.firstName.text!, lastName: self.lastName.text!, emailAddress: self.email.text!)
                DatabaseManager.shared.insertUser(with:newUser)
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register"
        // Do any additional setup after loading the view.
    }
    //    dismisses the keyboard
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
            super.touchesBegan(touches, with: event)
        }
}


extension UIViewController{

    func showToast(message : String, seconds: Double){
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.view.backgroundColor = .black
            alert.view.alpha = 0.5
            alert.view.layer.cornerRadius = 15
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
                alert.dismiss(animated: true)
            }
        }
 }
