//
//  protocol.swift
//  FoodFlickInterview
//
//  Created by Reyhan on 04/08/21.
//

import Foundation

protocol tableViewCellProtocol {
    func addFoodToCart(food: Food, quantity: Int, status: String)
}
protocol collectionViewCellProtocol{
    func changeTypeFood(id: Int, type: String)
}
