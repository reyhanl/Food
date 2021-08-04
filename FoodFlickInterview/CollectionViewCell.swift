//
//  CollectionViewCell.swift
//  FoodFlickInterview
//
//  Created by Reyhan on 04/08/21.
//  Copyright © 2021 Reyhan Muhammad. All rights reserved.

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var buttonMenu: UIButton!
    var delegate: collectionViewCell!
    var id: Int!
    var type: String!{
        didSet{
            buttonMenu.setTitle(type, for: .normal)
        }
    }
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonMenu.addTarget(self, action: #selector(changeTable), for: .touchUpInside)
        // Initialization code
    }
    @objc func changeTable(){
        delegate.typeFood(id: id ?? 0, type: type ?? "")
    }

}
