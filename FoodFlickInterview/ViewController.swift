//
//  FoodViewController.swift
//  Sokin
//
//  Created by Reyhan on 03/08/21.
//  Copyright © 2021 Final Climax. All rights reserved.
//

import UIKit
import FirebaseFirestore
class FoodViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    //Cart View
    @IBOutlet weak var imageCart: UIImageView!
    @IBOutlet weak var numberOfCartLabel: UILabel!
    @IBOutlet weak var viewInsideCart: UIView!
    @IBOutlet weak var cart: UIView!
    
    @IBOutlet weak var delegate: UICollectionViewFlowLayout!
    //cartPosition
    var normalY = 0
    var offsetY = 0
    var numberOfOrder: Int = 0
    var food: [Food] = []{
        didSet{
            if food.count != 0{
                carts()
                numberOfCartLabel.text = "\(food.count)"
            }else{
                cartOut()
            }
        }
    }
    var positionCart: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var collections: [String] = []
    var expectedOutcome = 0
    var currentActiveIndex: Int = 0
    var currentCollection: String = "Healthy"
    var group = DispatchGroup()
    var typeFood: [String:[Food]] = [:]
    var cartList: [String:[Food]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        collectionView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "tableViewCell")
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        getFoodType()
        setupView()
        // Do any additional setup after loading the view.
    }
   
    func setupView(){
        tableView.tableHeaderView = UIView()
        
        cart.frame = CGRect(x: 20, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width - 40, height: 56)
        normalY = Int(UIScreen.main.bounds.height - 100)
        offsetY = Int(UIScreen.main.bounds.height + 100)
        viewInsideCart.bounds = CGRect(x: 20, y: 9, width: 38, height: 38)
        numberOfCartLabel.frame =  CGRect(x: viewInsideCart.bounds.midX, y: viewInsideCart.bounds.height / 2, width: 11, height: 20)
        imageCart.frame = CGRect(x: cart.frame.maxX - 80, y: viewInsideCart.frame.minY, width: 40, height: 40)
        cartOut()
        cart.isHidden = false

    }
    override func viewWillAppear(_ animated: Bool) {
       

    }
    func getFoodType(){
        
      
        Firestore.firestore().collection("FoodType").getDocuments { [self] (snap, error) in
            if let error = error {
                print(#function, error.localizedDescription)
            } else {
                print(snap)
                var documents = snap!.documents
                group.enter()

                for i in documents{
                    var data = i.data()
                    collections.append(data["name"] as! String)
                    group.enter()
                    getFood(typeFood: data["name"] as! String, completion: {
                        group.leave()
                        
                    })
                }
                group.leave()

                
            }
            group.notify(queue: .main) {
                collectionView.reloadData()
                self.changeTable()
            }
        }
        
        
    }
    func carts(){
        UIView.animate(withDuration: 0.3) { [self] in
            self.cart.frame = CGRect(x: cart.frame.minX, y: CGFloat(normalY), width: cart.frame.width, height: cart.frame.height)
        }
    }
    func cartOut(){
        cart.translatesAutoresizingMaskIntoConstraints = false
        for i in cart.constraints{
            cart.removeConstraint(i)

        }
        UIView.animate(withDuration: 0.3) { [self] in
            self.cart.frame = CGRect(x: cart.frame.minX, y: CGFloat(offsetY), width: cart.frame.width, height: cart.frame.height)
        }
    }
    func getFood(typeFood: String,completion: @escaping() -> Void){
        
        Firestore.firestore().collection(typeFood).getDocuments { [self]
            (snap, error) in

            if let error = error {
                print(#function, error.localizedDescription)
            } else {
                var foods: [Food] = []
                let dispatch = DispatchGroup()
                for i in  snap!.documents{
                    dispatch.enter()
                    let data = i.data()
                    let image = data["image"] as! String
                    var url : URL!
                    if image == "nil"{
                        url = URL(string: "https://www.solidbackgrounds.com/images/2560x1600/2560x1600-dark-gray-solid-color-background.jpg")!
                    }else{
                        url = URL(string: image)
                    }
                   
                    downloadImage(from: url, completion: { (image) in
                        foods.append(Food(name: data["name"] as! String, image: image, price: data["price"] as! Int,promo: data["promo"] as! Bool, love: data["love"] as! Bool, normalPrice: (data["promo"] as! Bool) ? data["normalPrice"] as! Int : 0 , description: data["description"] as! String))
                        dispatch.leave()
                    })
                    
                }
                dispatch.notify(queue: .main) {
                    self.typeFood[typeFood] = foods
                    completion()
                }
               
            }
        }
    }
    func downloadImage(from url: URL,completion: @escaping(UIImage) -> Void)  {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                completion(UIImage(data: data) ?? UIImage())
            }
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func addFood(food: Food, status: String){
        if status != "substract"{
            var array : [Food] = []

            if cartList[currentCollection] != nil{
                array = cartList[currentCollection] ?? []

            }
            array.append(food)
            cartList[currentCollection] = array
            
        }else{
            var data = cartList[currentCollection]
            for (index,i) in data!.enumerated(){
                if i.name == food.name{
                    data?.remove(at: index)
                    break
                }
                
            }
            cartList[currentCollection] = data
        }
    }
    func changeTable(){
        tableView.reloadData()
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
extension FoodViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(typeFood.count)
        if typeFood.count != 0{
            print(typeFood[currentCollection]!.count)
            return typeFood[currentCollection]!.count

        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if typeFood.count != 0{
            var cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
            
            cell.type = currentCollection
            var array = cartList[currentCollection]?.filter{$0.name == typeFood[currentCollection]![indexPath.row].name}
            cell.food = typeFood[currentCollection]![indexPath.row]
            cell.quantity = array?.count ?? 0
            cell.delegate = self
            return cell
        }else{
            return UITableViewCell()
        }
            
       

        
    }
}

extension FoodViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collections != nil{
            return collections.count

        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        if indexPath.row == currentActiveIndex{
            cell.view.backgroundColor = .red
        }else{
            cell.view.backgroundColor = .white
        }
        cell.id = indexPath.row
        cell.delegate = self
        cell.type = collections[indexPath.row]
        return cell
    }
    
    
    
}
extension FoodViewController: clickCell{
    func food(id: Food, quantity: Int, status: String) {
        if status == "substract"{
            for (index,i) in food.enumerated(){
                if i.name == id.name{
                    food.remove(at: index)
                    addFood(food: id, status: status)

                    break
                }
            }
        }else{
            addFood(food: id, status: status)
            food.append(id)
        }
    }
}
extension FoodViewController: collectionViewCell{
    func typeFood(id: Int, type: String) {
        currentCollection = type
        var previousActiveIndex = currentActiveIndex
        currentActiveIndex = id

        collectionView.reloadItems(at: [IndexPath(item: previousActiveIndex, section: 0),IndexPath(item: currentActiveIndex, section: 0) ])

        changeTable()
           
    }
}
class Food{
    var id: String!
    var name: String!
    
    var image: UIImage!
    var url: String!
    var price: Int!
    var promo: Bool!
    var love:  Bool!
    var normalPrice: Int!
    var description: String!
    init( name: String, image: UIImage, price: Int, promo: Bool, love: Bool, normalPrice: Int!, description : String){
        self.name = name
        self.image =  image
        self.description = description
        self.price = price
        self.promo = promo
        self.love = love
        self.normalPrice = normalPrice
    }
    
}

protocol clickCell {
    func food(id: Food, quantity: Int, status: String)
}
protocol collectionViewCell{
    func typeFood(id: Int, type: String)
}
