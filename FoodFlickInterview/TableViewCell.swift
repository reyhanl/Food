//
//  TableViewCell.swift
//  FoodFlickInterview
//
//  Created by Reyhan on 03/08/21.
//  Copyright © 2021 Reyhan Muhammad. All rights reserved.
//

import UIKit
import FirebaseFirestore
class TableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var promoLabel: UILabel!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var images: UIImageView!
    @IBOutlet weak var normalPriceLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!

    var delegate: tableViewCellProtocol!
    var type = ""
    var food: Food!{
        didSet{
            nameLabel.text = food.name
//            imageView.image = food.image
            priceLabel.text = "\(food.price ?? 0)"
            images.image = food.image
            descriptionLabel.text = food.description
            if food.promo{
                promoLabel.isHidden = false
                normalPriceLabel.isHidden = false
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(food.normalPrice ?? 0)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                normalPriceLabel.attributedText = attributeString

            }else{
                promoLabel.isHidden = true
                normalPriceLabel.isHidden = true
            }
            if food.love{
                loveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }else{
                loveButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            
        }
    }
    var quantity: Int = 0{
        didSet{
            quantityLabel.text = "\(quantity)"
            if quantity == 0{
                addToCartButton.isHidden = false
                plusButton.isHidden = true
                minusButton.isHidden = true
                quantityLabel.isHidden = true
            }else{
                addToCartButton.isHidden = true
                plusButton.isHidden = false
                minusButton.isHidden = false
                quantityLabel.isHidden = false
            }
        }
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        loveButton.addTarget(self, action: #selector(love), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(decreaseFood), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increaseFood), for: .touchUpInside)
        // Initialization code
    }
    @objc func love(){
        if food.love{
            Firestore.firestore().collection(type).document(food.name).updateData(["love": false])
            food.love = false
            loveButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }else{
            Firestore.firestore().collection(type).document(food.name).updateData(["love": true])
            food.love = true
            
            loveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
    }
     @objc func addToCart(){
         delegate.addFoodToCart(food: food, quantity: quantity + 1, status: "plus")
        quantity += 1
     }
     @objc func increaseFood(){
         delegate.addFoodToCart(food: food, quantity: quantity + 1, status: "plus")
        quantity += 1
     }
     @objc func decreaseFood(){
         delegate.addFoodToCart(food: food, quantity: quantity - 1, status: "substract")
        quantity -= 1
     }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
