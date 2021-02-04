//
//  Category.swift
//  ToDoList
//
//  Created by Victor Lee on 12/27/20.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
