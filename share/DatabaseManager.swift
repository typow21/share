//
//  DatabaseManager.swift
//  share
//
//  Created by Tyler Powell on 4/30/21.
//

import Foundation
import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation

final class DatabaseManager{
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()

}
// MARK: - Account Management

struct ShareUser {
    let id: String
    let firstName: String
    let lastName: String
    let emailAddress: String
}

extension DatabaseManager{
    
    public func insertUser(with user: ShareUser){
        database.child("users").child(user.id).setValue([
             "firstName" : user.firstName,
             "lastName" : user.lastName,
            "email" : user.emailAddress])
    }
    
    public func getUser(with id: String, completion: @escaping (ShareUser) -> Void ){
        database.child("users").child(id).observe(.value, with: { (snapshot) in
                DispatchQueue.main.async {
                    let value = snapshot.value! as! NSDictionary
                    let first_name = value["firstName"]! as! String
                    let last_name = value["lastName"]! as! String
                    let email = value["email"]! as! String
                    let newUser = ShareUser(id: id, firstName: first_name, lastName: last_name, emailAddress: email)
                    completion(newUser)
                }
          })
    }
}

// MARK: - Item Management
class Item {
    var id: String
    let title: String
    let description: String
    let seller: ShareUser?
    let buyer: ShareUser?
    
    init(id: String, title: String, description: String, image_url: String, seller: ShareUser?, buyer: ShareUser?) {
        self.id = id
        self.title = title
        self.description = description
        if(buyer != nil){
            self.buyer = buyer!
        }else{
            self.buyer = nil
        }
        if (seller != nil){
            self.seller = seller!
        }else{
            self.seller = nil
        }
    }
}

extension DatabaseManager{
    
    public func add_item(newItem: Item){
        let item = newItem
        let item_ref =  database.child("items").childByAutoId()
        item_ref.setValue([
                "title" : item.title,
                "description" : item.description,
                "seller": ["id": item.seller!.id,
                           "firstName": item.seller!.firstName,
                           "lastName" : item.seller!.lastName,
                           "emailAddress": item.seller!.emailAddress]])
        let item_id = item_ref.key
        item.id = item_id!
    }
    
    
//    Share items
    public func getAllNonUserAndNotRentedItems(with id: String,completion: @escaping([Item]) -> ()){
        var items: [Item] = []
        database.child("items").getData { (error, snapshot) in
            if error != nil {
                //print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                DispatchQueue.main.async {
                    //print("Got data \(snapshot.value!)")
                    let value = snapshot.value! as! NSDictionary
                    for x in value{
//                        //print("X",x)
                        let obj = x.value as! NSDictionary
                        let sellerDict = obj["seller"]! as! NSDictionary
                        let seller = ShareUser(id: sellerDict["id"]! as! String, firstName: sellerDict["firstName"]! as! String, lastName: sellerDict["lastName"]! as! String, emailAddress: sellerDict["emailAddress"]! as! String)
                        var buyer: ShareUser
                        let item: Item
                        if(obj["buyer"] != nil){
                            let buyerDict = obj["buyer"]! as! NSDictionary
                            buyer = ShareUser(id: buyerDict["id"]! as! String, firstName: buyerDict["firstName"]! as! String, lastName: buyerDict["lastName"]! as! String, emailAddress: buyerDict["emailAddress"]! as! String)
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: buyer)
                        }else{
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: nil)
                        }
                        
                        if(item.seller!.id != id && item.buyer == nil){
//                            //print(item.seller!.id)
//                            //print(id)
                            items.append(item)
                        }
                    }
                    completion(items)
                }
            }
            else {
                //print("No data available")
            }
        }
    }
    
    
    public func getAllUserItems(with id: String, completion: @escaping([Item]) -> ()){
        var items: [Item] = []
        database.child("items").getData { (error, snapshot) in
            if error != nil {
                //print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                DispatchQueue.main.async {
                    //print("Got data \(snapshot.value!)")
                    let value = snapshot.value! as! NSDictionary
                    for x in value{
//                        //print("X",x)
                        let obj = x.value as! NSDictionary
                        let sellerDict = obj["seller"]! as! NSDictionary
                        let seller = ShareUser(id: sellerDict["id"]! as! String, firstName: sellerDict["firstName"]! as! String, lastName: sellerDict["lastName"]! as! String, emailAddress: sellerDict["emailAddress"]! as! String)
                        var buyer: ShareUser
                        let item: Item
                        if(obj["buyer"] != nil){
                            let buyerDict = obj["buyer"]! as! NSDictionary
                            buyer = ShareUser(id: buyerDict["id"]! as! String, firstName: buyerDict["firstName"]! as! String, lastName: buyerDict["lastName"]! as! String, emailAddress: buyerDict["emailAddress"]! as! String)
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: buyer)
                        }else{
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: nil)
                        }
                       
                        if(item.seller!.id == id){
                            items.append(item)
                        }
                    }
                    completion(items)
                }
            }
            else {
                //print("No data available")
            }
        }
    }
    
    public func getAllItemsRentedFromUser(with id: String, completion: @escaping([Item]) -> ()){
        var items: [Item] = []
        database.child("items").getData { (error, snapshot) in
            if error != nil {
                //print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                DispatchQueue.main.async {
                    //print("Got data \(snapshot.value!)")
                    let value = snapshot.value! as! NSDictionary
                    for x in value{
//                        //print("X",x)
                        let obj = x.value as! NSDictionary
                        let sellerDict = obj["seller"]! as! NSDictionary
                        let seller = ShareUser(id: sellerDict["id"]! as! String, firstName: sellerDict["firstName"]! as! String, lastName: sellerDict["lastName"]! as! String, emailAddress: sellerDict["emailAddress"]! as! String)
                        var buyer: ShareUser
                        let item: Item
                        if(obj["buyer"] != nil){
                            let buyerDict = obj["buyer"]! as! NSDictionary
                            buyer = ShareUser(id: buyerDict["id"]! as! String, firstName: buyerDict["firstName"]! as! String, lastName: buyerDict["lastName"]! as! String, emailAddress: buyerDict["emailAddress"]! as! String)
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: buyer)
                        }else{
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: nil)
                        }
                       
                        if(item.seller!.id == id && item.buyer != nil){
                            items.append(item)
                        }
                    }
                    completion(items)
                }
            }
            else {
                //print("No data available")
            }
        }
        
    }
    
    public func getUserItemsNotRented(with id: String, completion: @escaping([Item]) -> ()){
        var items: [Item] = []
        database.child("items").getData { (error, snapshot) in
            if error != nil {
                //print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                DispatchQueue.main.async {
                    //print("Got data \(snapshot.value!)")
                    let value = snapshot.value! as! NSDictionary
                    for x in value{
//                        //print("X",x)
                        let obj = x.value as! NSDictionary
                        let sellerDict = obj["seller"]! as! NSDictionary
                        let seller = ShareUser(id: sellerDict["id"]! as! String, firstName: sellerDict["firstName"]! as! String, lastName: sellerDict["lastName"]! as! String, emailAddress: sellerDict["emailAddress"]! as! String)
                        var buyer: ShareUser
                        let item: Item
                        if(obj["buyer"] != nil){
                            let buyerDict = obj["buyer"]! as! NSDictionary
                            buyer = ShareUser(id: buyerDict["id"]! as! String, firstName: buyerDict["firstName"]! as! String, lastName: buyerDict["lastName"]! as! String, emailAddress: buyerDict["emailAddress"]! as! String)
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: buyer)
                        }else{
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: nil)
                        }
                        if(item.seller!.id == id && item.buyer == nil){
                            items.append(item)
                        }
                    }
                    completion(items)
                }
            }
            else {
                //print("No data available")
            }
        }
    }
    
    public func getAllItemsRentedByUser(with id: String, completion: @escaping([Item]) -> ()){
        var items: [Item] = []
        database.child("items").getData { (error, snapshot) in
            if error != nil {
                ////print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                DispatchQueue.main.async {
//                    //print("Got data \(snapshot.value!)")
                    let value = snapshot.value! as! NSDictionary
                    for x in value{
//                        //print("X",x)
                        let obj = x.value as! NSDictionary
                        let sellerDict = obj["seller"]! as! NSDictionary
                        let seller = ShareUser(id: sellerDict["id"]! as! String, firstName: sellerDict["firstName"]! as! String, lastName: sellerDict["lastName"]! as! String, emailAddress: sellerDict["emailAddress"]! as! String)
                        var buyer: ShareUser
                        let item: Item
                        if(obj["buyer"] != nil){
                            let buyerDict = obj["buyer"]! as! NSDictionary
                            buyer = ShareUser(id: buyerDict["id"]! as! String, firstName: buyerDict["firstName"]! as! String, lastName: buyerDict["lastName"]! as! String, emailAddress: buyerDict["emailAddress"]! as! String)
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: buyer)
                        }else{
                            item = Item(id: x.key as! String, title: obj["title"]! as! String, description: obj["description"]! as! String, image_url: "", seller: seller, buyer: nil)
                        }
                        if(item.buyer != nil && item.buyer!.id == id){
                            items.append(item)
                            
                        }
                    }
                    completion(items)
                }
            }
            else {
                //print("No data available")
            }
        }
    }
    
    public func editItem(with item: Item){
        if( item.buyer != nil){
            database.child("items").child(item.id).setValue([
                "title" : item.title,
                "description" : item.description,
                "seller": ["id": item.seller!.id,
                           "firstName": item.seller!.firstName,
                           "lastName" : item.seller!.lastName,
                           "emailAddress": item.seller!.emailAddress],
            
                "buyer": ["id": item.buyer!.id,
                           "firstName": item.buyer!.firstName,
                           "lastName" : item.buyer!.lastName,
                           "emailAddress": item.buyer!.emailAddress]
            ]
            )
        }else{
            database.child("items").child(item.id).setValue([
                "title" : item.title,
                "description" : item.description,
                "seller": ["id": item.seller!.id,
                           "firstName": item.seller!.firstName,
                           "lastName" : item.seller!.lastName,
                           "emailAddress": item.seller!.emailAddress],
            ]
            )
        }
    }
    
    public func deleteItem(with itemID: String){
        database.child("items").child(itemID).removeValue()
    }
}

