//
//  Food.swift
//  FoodFlickInterview
//
//  Created by Reyhan on 04/08/21.
//
import UIKit
class Food{
    var id: String!
    var name: String!
    var description: String!
    var image: UIImage!
    var url: String!
    var price: Int!
    var promo: Bool!
    var love:  Bool!
    var normalPrice: Int!
    
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
