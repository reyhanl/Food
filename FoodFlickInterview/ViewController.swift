//
//  FoodViewController.swift
//  FoodFlickInterview
//
//  Created by Reyhan on 03/08/21.
//   Copyright © 2021 Reyhan Muhammad. All rights reserved.
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
    
    
    //MARK: cartPosition
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
    var currentActiveIndex: Int = 0
    var currentCollection: String = ""
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
        numberOfCartLabel.frame =  CGRect(x: viewInsideCart.bounds.midX, y: viewInsideCart.bounds.midY , width: 11, height: 20)
        imageCart.frame = CGRect(x: cart.frame.maxX - 80, y: viewInsideCart.frame.minY, width: 40, height: 40)
        let redCenter = cart.convert(viewInsideCart.center, to: viewInsideCart)

        numberOfCartLabel.center = redCenter
        cartOut()
        cart.isHidden = false

    }
    func getFoodType(){
        Firestore.firestore().collection("FoodType").getDocuments { [self] (snap, error) in
            if let error = error {
                print(#function, error.localizedDescription)
            } else {
                let documents = snap!.documents
                group.enter()

                for i in documents{
                    let data = i.data()
                    collections.append(data["name"] as! String)
                    group.enter()
                    getFood(typeFood: data["name"] as! String, completion: {
                        group.leave()
                        
                    })
                }
                group.leave()

                
            }
            group.notify(queue: .main) {
                currentCollection = collections[0]
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
                    if image == ""{
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
            DispatchQueue.main.async() {  
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
            
            cell.type = currentCollection
            let array = cartList[currentCollection]?.filter{$0.name == typeFood[currentCollection]![indexPath.row].name}
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
        return collections.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
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
extension FoodViewController: tableViewCellProtocol{
    func addFoodToCart(food: Food, quantity: Int, status: String) {
        if status == "substract"{
            for (index,i) in self.food.enumerated(){
                if i.name == food.name{
                    self.food.remove(at: index)
                    addFood(food: food, status: status)

                    break
                }
            }
        }else{
            addFood(food: food, status: status)
            self.food.append(food)
        }
    }
}
extension FoodViewController: collectionViewCellProtocol{
    func changeTypeFood(id: Int, type: String) {
        currentCollection = type
        let previousActiveIndex = currentActiveIndex
        currentActiveIndex = id
        var arrayOfIndex : [Int] = []
        for cell in collectionView.visibleCells {
               let indexPath = collectionView.indexPath(for: cell)
            arrayOfIndex.append(indexPath?.row ?? 0)
        }
        if arrayOfIndex.contains(previousActiveIndex){
            collectionView.reloadItems(at: [IndexPath(item: previousActiveIndex, section: 0),IndexPath(item: currentActiveIndex, section: 0) ])

        }else{
            collectionView.reloadItems(at: [IndexPath(item: currentActiveIndex, section: 0) ])

        }

        changeTable()
           
    }
}
