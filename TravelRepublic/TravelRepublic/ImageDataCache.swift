//
//  ImageDataCache.swift
//  TravelRepublic
//
//  Created by Guillaume Manzano on 08/02/2017.
//  Copyright © 2017 Guillaume Manzano. All rights reserved.
//

import Foundation
import UIKit

struct ImageDataCache
{
    init(image: UIImage, id: String)
    {
        ImageSaved = image
        Id = id
    }
    var Id: String = ""
    var ImageSaved: UIImage
}
