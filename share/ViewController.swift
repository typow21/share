//
//  ViewController.swift
//  share
//
//  Created by Tyler Powell on 5/2/2021
//

import UIKit
import Firebase
class ViewController: UIViewController {
    
    private let database = Database.database().reference()
    //07. Connect the textView Object
    
    @IBOutlet weak var value_label: UILabel!
    
    @IBOutlet weak var item_title: UILabel!
    @IBOutlet weak var item_description: UITextView!
    @IBOutlet weak var reserveBtn: UIButton!
    
    @IBOutlet weak var dbText: UITextField!
    
    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var renter: UILabel!
    
    
    @IBAction func database_test(_ sender: Any) {
        let object: [String: Any] = [
            "name" :dbText.text! as NSObject,
            "Youtube":"yes"
        ]
        database.child("something").setValue(object)
        self.viewDidLoad()
    }
    
    
    var item: Item?
    var actionType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, "item: ", item!)
        database.child("something").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [String: Any] else{
                return
            }
            print("Value: \(value)")
            self.value_label.text = value["name"] as? String
        })
        
        // Do any additional setup after loading the view.
        reserveBtn.layer.cornerRadius = 15
        DatabaseManager.shared.getUser(with: Auth.auth().currentUser!.uid, completion:{newUser in
            let id = newUser.id
            
            //        share items
            if(self.item!.seller!.id != id && self.item!.buyer == nil){
                print("this is a share item")
                self.owner.text = "Owned by: \(self.item!.seller!.emailAddress)"
                self.renter.text = "No one is currently renting this item"
                self.actionType = "reserve"
            }
            
//            getAllUserItems
            if(self.item!.seller!.id == id ){
                self.owner.text = "You own this item"
                if(self.item!.buyer == nil){
                    self.renter.text = "No one is currently renting this item"
                    self.reserveBtn.backgroundColor = UIColor.red
                    self.reserveBtn.setTitle("Delete Item", for: .normal)
                    self.actionType = "delete"
                }else{
                    self.renter.text = "Rented by: \(self.item!.buyer!.emailAddress)"
                    self.reserveBtn.isHidden = true
                }
            }
            
//            getAllItemsRentedFromUser
            if(self.item!.seller!.id == id && self.item!.buyer != nil){
                print("This is your item rented by another user")
                self.owner.text = "You own this item"
                self.renter.text = "Rented by: \(self.item!.buyer!.emailAddress)"
                self.reserveBtn.isHidden = true
            }
            
//            getUserItemsNotRented
            if(self.item!.seller!.id == id && self.item?.buyer == nil){
                print("This is your item and has not yet been rented")
                self.owner.text = "You own this item"
                self.renter.text = "No one is currently renting this item"
                self.reserveBtn.backgroundColor = UIColor.red
                self.reserveBtn.setTitle("Delete Item", for: .normal)
                self.actionType = "delete"
            }
            
//            getAllItemsRentedByUser
            if(self.item?.buyer != nil && self.item!.buyer!.id == id){
                print("This is an item you are renting from another user")
                self.owner.text = "Owned by: \(self.item!.seller!.emailAddress)"
                self.renter.text = "You are renting this item"
                self.reserveBtn.backgroundColor = UIColor.red
                self.reserveBtn.setTitle("Return Item", for: .normal)
                self.actionType = "return"
            }
        })
       
    }
    
    @IBAction func reserveItem(_ sender: Any) {
        
        let userid = Auth.auth().currentUser!.uid
        
        DatabaseManager.shared.getUser(with: Auth.auth().currentUser!.uid, completion:{newUser in
            if(self.actionType == "reserve"){
                let buyer = ShareUser(id: userid, firstName: newUser.firstName, lastName: newUser.lastName, emailAddress: newUser.emailAddress)
                let editedItem = Item(id: self.item!.id, title: self.item!.title, description: self.item!.description, image_url: "", seller: self.item!.seller, buyer: buyer)
                DatabaseManager.shared.editItem(with: editedItem)
                self.dismiss(animated: true, completion: nil)
            }
            if(self.actionType == "delete"){
                DatabaseManager.shared.deleteItem(with: self.item!.id)
                self.dismiss(animated: true, completion: nil)
            }
            if(self.actionType == "return"){
                let editedItem = Item(id: self.item!.id, title: self.item!.title, description: self.item!.description, image_url: "", seller: self.item!.seller, buyer: nil)
                DatabaseManager.shared.editItem(with: editedItem)
                print("editing item")
                self.dismiss(animated: true, completion: nil)
//                print(self.presentingViewController)
            }
            
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function, "item: ", item!)
        if let i = item {
            item_title.text = i.title
            item_description.text = i.description
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
    }

}
