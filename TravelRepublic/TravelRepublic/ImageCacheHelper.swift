//
//  ImageCacheHelper.swift
//  TravelRepublic
//
//  Created by Guillaume Manzano on 08/02/2017.
//  Copyright © 2017 Guillaume Manzano. All rights reserved.
//

import Foundation
import UIKit

class ImageCacheHelper
{
    private static var imageList =  NSMutableArray()
    
    static func GetImageById(id: String) -> UIImage?
    {
        for item in imageList
        {
            if (item as! ImageDataCache).Id == id
            {
                return (item as! ImageDataCache).ImageSaved
            }
        }
        return nil
    }
    
    static func SaveImage(image: UIImage, id: String)
    {
        let item = ImageDataCache(image: image, id: id)
        imageList.add(item)
    }
    
}
