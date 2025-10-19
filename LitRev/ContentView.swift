//
//  ContentView.swift
//  LitRev
//
//  Main entry point - navigates to Projects screen
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ProjectsListView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, DataController.preview.container.viewContext)
}

