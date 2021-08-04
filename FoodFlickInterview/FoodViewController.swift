////
////  FoodViewController.swift
////  Sokin
////
////  Created by Reyhan on 03/08/21.
////  Copyright © 2021 Final Climax. All rights reserved.
////
//
//import UIKit
//import FirebaseFirestore
//class FoodViewController: UIViewController {
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var tableView: UITableView!
//    var numberOfOrder: Int = 0
//    var food: [Food] = []
//    var collections: [String]!
//    var expectedOutcome = 0
//    var currentCollection: String = "Healthy"
//    var group = DispatchGroup()

//    var typeFood: [String:[Food]] = [:]
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        collectionView.dataSource = self
//        tableView.dataSource = self
//        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "tableViewCell")
////        collectionView.register(UINib(nibName: "collectionViewCell", bundle: nil), forCellReuseIdentifier: "collectionViewCell")
//        getFoodType()
//        // Do any additional setup after loading the view.
//    }
//    func getFoodType(){
//        
//      
//        Firestore.firestore().collection("FoodType").getDocuments { [self] (snap, error) in
//            if let error = error {
//                print(#function, error.localizedDescription)
//            } else {
//                print(snap)
//                var documents = snap!.documents
//                group.enter()
//
//                for i in documents{
//                    var data = i.data()
//                    group.enter()
//                    getFood(typeFood: data["name"] as! String, completion: {
//                        group.leave()
//                        
//                    })
//                }
//                group.leave()
//
//                
//            }
//            group.notify(queue: .main) {
//                self.changeTable()
//            }
//        }
//        
//        
//    }
//    func getFood(typeFood: String,completion: @escaping() -> Void){
//        
//        
//        Firestore.firestore().collection(typeFood).getDocuments { (snap, error) in
//            if let error = error {
//                print(#function, error.localizedDescription)
//            } else {
//                var foods: [Food] = []
//                for i in  snap!.documents{
//                    var data = i.data()
//                    foods.append(Food(name: data["name"] as! String, image: UIImage(), price: data["price"] as! Int ))
//                }
//                self.typeFood[typeFood] = foods
//                completion()
//            }
//        }
//    }
//    func changeTable(){
//        tableView.reloadData()
//    }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//extension FoodViewController: UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(typeFood.count)
//        if typeFood.count != 0{
//            print(typeFood[currentCollection]!.count)
//            return typeFood[currentCollection]!.count
//
//        }else{
//            return 0
//        }
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//            var cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
//            return cell
//       
//
//        
//    }
//}
//
//extension FoodViewController: UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return collections.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        return cell
//    }
//    
//    
//}
//extension FoodViewController: clickCell{
//    func food(id: Food, quantity: Int, status: String) {
//        if status == "substract"{
//            for (index,i) in food.enumerated(){
//                if i.name == id.name{
//                    food.remove(at: index)
//                }
//            }
//        }else{
//            food.append(id)
//        }
//    }
//}
//extension FoodViewController: collectionViewCell{
//    func typeFood(id: Int, type: String) {
//        currentCollection = type
//        changeTable()
////            for (index,i) in food.enumerated(){
////                if i.name == id.name{
////                    food.remove(at: index)
////                }
////            }
//    }
//}
//class Food{
//    var id: String!
//    var name: String!
//    var image: UIImage!
//    var price: Int!
//    init( name: String, image: UIImage!, price: Int){
//        self.name = name
//        self.image = image
//        self.price = price
//    }
//}
//
//protocol clickCell {
//    func food(id: Food, quantity: Int, status: String)
//}
//protocol collectionViewCell{
//    func typeFood(id: Int, type: String)
//}
