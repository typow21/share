//
//  AddItemViewController.swift
//  share
//
//  Created by Tyler Powell on 5/1/21.
//

import UIKit
import Firebase

class AddItemViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareBtn.layer.cornerRadius = 15
        // Do any additional setup after loading the view.
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        
        if(title == "" && description == ""){
            message.text = "Please enter a title and description"
        }
        let title = self.titleField.text!
        let description = self.descriptionField.text!
        let sellerUserAuthid = Auth.auth().currentUser!.uid
        DatabaseManager.shared.getUser(with: sellerUserAuthid, completion:{newUser in
            print(newUser)
            let newItem = Item(id: "", title: title, description: description, image_url: "", seller: newUser, buyer: nil)
            newItem.id = "1"
            DatabaseManager.shared.add_item(newItem: newItem)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
//    dismisses the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

}
