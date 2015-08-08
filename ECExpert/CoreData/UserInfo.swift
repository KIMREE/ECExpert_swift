//
//  UserInfo.swift
//  
//
//  Created by Fran on 15/7/31.
//
//

import Foundation
import CoreData

@objc(UserInfo) class UserInfo: NSManagedObject {

    @NSManaged var userId: String
    @NSManaged var name: String
    @NSManaged var portraitUri: String
    
}
