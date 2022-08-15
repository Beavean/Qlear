//
//  Category.swift
//  Qlear
//
//  Created by Beavean on 15.08.2022.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var items = List<Item>()
}
