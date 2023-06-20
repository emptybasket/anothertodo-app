//
//  Another_ToDo_AppApp.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/20/23.
//

import SwiftUI

@main
struct Another_ToDo_AppApp: App {
    var body: some Scene {
        WindowGroup {
            let _ = UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
            ContentView()
        }
        .modelContainer(for: [ToDo.self])
    }
}
