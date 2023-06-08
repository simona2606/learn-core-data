//
//  MoviePersistenceController.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import CoreData

class MoviePersistenceController: ObservableObject {
    var persistentController = NSPersistentContainer(name: "Movie")
    
    init() {
        
    }
}
