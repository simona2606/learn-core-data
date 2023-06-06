//
//  LearnCoreDataApp.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import SwiftUI

@main
struct LearnCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
