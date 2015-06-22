//
//  KMAnnotation.swift
//  ECExpert
//
//  Created by Fran on 15/6/16.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class KMAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var image: UIImage
    var title: String
    var index: Int!
    
    init(coordinate: CLLocationCoordinate2D, title: String, image: UIImage) {
        self.coordinate = coordinate
        self.title = title
        self.image = image
    }
}
