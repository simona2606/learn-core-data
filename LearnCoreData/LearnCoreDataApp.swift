//
//  LearnCoreDataApp.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import SwiftUI

@main
struct LearnCoreDataApp: App {
    let viewModel = MoviesViewModel()

    var body: some Scene {
        WindowGroup {
            MoviesView()
                .environmentObject(viewModel)
        }
    }
}
