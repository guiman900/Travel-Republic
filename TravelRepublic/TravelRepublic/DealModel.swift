//
//  DealModel.swift
//  TravelRepublic
//
//  Created by Guillaume Manzano on 08/02/2017.
//  Copyright © 2017 Guillaume Manzano. All rights reserved.
//

import Foundation

struct DealModel
{
    init(id: String, title: String, type: String, country: Int, price: Int)
    {
        self.id = id
        self.title = title
        self.type = type
        self.country = country
        self.price = price
    }

    let id: String?
    let title: String?
    let type: String?
    let country: Int?
    let price: Int?
}
