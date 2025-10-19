//
//  LitRevApp.swift
//  LitRev
//
//  Created by AI Assistant
//

import SwiftUI

@main
struct LitRevApp: App {
    @StateObject private var dataController = DataController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onAppear {
                    // Create sample data on first launch
                    SampleDataHelper.createSampleDataIfNeeded(
                        context: dataController.container.viewContext
                    )
                }
        }
    }
}

