//
//  MoviePersistenceController.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import CoreData

class MoviePersistenceController: ObservableObject {
    var persistentContainer = NSPersistentContainer(name: "MovieCD")
    
    init() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("error = \(error)")
            }
            
        }
    }
}
