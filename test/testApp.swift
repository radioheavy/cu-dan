//
//  testApp.swift
//  test
//
//  Created by İsmail Oktay Dak on 30.09.2024.
//

import SwiftUI

@main
struct testApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
