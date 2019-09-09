//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Борис Крисько on 9/5/19.
//  Copyright © 2019 Alexey Efimov. All rights reserved.
//

import RealmSwift

let realm = try! Realm()


class StorageManager {
    
    static func saveTask(task: Task) {
        try! realm.write {
            realm.add(task)
        }
    }
}
