//
//  Item.swift
//  Qlear
//
//  Created by Beavean on 15.08.2022.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date?
    @Persisted(originProperty: "items") var parentCategory:LinkingObjects<Category>
}
