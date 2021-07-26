//
//  AllUserItemsViewController.swift
//  share
//
//  Created by Tyler Powell on 5/2/21.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

//struct Item {
//    let id: String
//    let title: String
//    let description: String
//    let image_url: String
//    let seller: ShareUser
//    let buyer: shareUser
//}



class AllUserItemsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {



    var itemSize: CGSize = CGSize(width: 0, height: 0)
    var items : [Item] = []
    var currentItem: Item?
    
    let semaphore = DispatchSemaphore(value: 0)
//    Got this code from somewhere online
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "All my items"
        
        self.collectionView.reloadData()
        validateAuth()
       
        self.navigationItem.setHidesBackButton(true, animated: false)
        if let layout = collectionView.collectionViewLayout as?
            UICollectionViewFlowLayout {

                let itemsPerRow: CGFloat = 2

                let padding: CGFloat = 10
                let totalPadding: CGFloat = padding * (itemsPerRow - 1)
                let individulaPadding: CGFloat = totalPadding / itemsPerRow
                let width = collectionView.frame.width / itemsPerRow - individulaPadding
                let height = width

                layout.minimumLineSpacing = padding
                layout.minimumInteritemSpacing = 10

                layout.estimatedItemSize = itemSize

                itemSize = CGSize(width: width, height: height)
            }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
        self.collectionView.reloadData()
        validateAuth()
        self.items = []
        self.navigationItem.setHidesBackButton(true, animated: false)
        DatabaseManager.shared.getAllUserItems(with: Auth.auth().currentUser!.uid , completion:{result in
            for x in result{
                self.items.append(x)
            }
            DispatchQueue.main.async{
                self.collectionView.reloadData()
            }
        })
    }
    
//    got this code from Swift: Firebase Chat App part 5
    private func validateAuth(){
        guard let vc = (storyboard?.instantiateViewController(identifier: "login") as? LoginViewController)else {
            print("failed to get vc from storyboard")
            return
        }
        print("validateAuth Called!")
        if Auth.auth().currentUser == nil{
            self.show(vc, sender: self)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }


     // MARK: - Navigation

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        currentItem = items[indexPath.row]
        print(#function,"Current item: ", currentItem!)
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }


     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index: Int = self.collectionView.indexPathsForSelectedItems![0].row
        print(index)
        currentItem = items[index]

        if(segue.identifier == "showDetail"){
            if let viewController = segue.destination as? ViewController {
                print(#function, "Current item",currentItem!)
                viewController.item = currentItem
                print(#function, "viewController.item",viewController.item!)
            }
        }
     }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell

        if let c = cell as? CollectionViewCell {
            c.label.text = items[indexPath.row].title
            c.layer.shadowPath = UIBezierPath(rect: c.bounds).cgPath
            c.layer.shadowColor = UIColor.black.cgColor
            c.layer.shadowOpacity = 1
            c.layer.shadowOffset = .zero
            c.layer.shadowRadius = 1
        }
        
        return cell
    }
}
