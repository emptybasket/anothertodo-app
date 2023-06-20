//
//  ToDo.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/20/23.
//

import Foundation
import SwiftData

@Model
final class ToDo: Identifiable {
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var isCompleted: Bool = false
    
    init(id: String = UUID().uuidString, name: String, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
    }
    
    static var sampleData: [ToDo] {
        [
            ToDo(name: "Create a sample project on swiftdata"),
            ToDo(name: "Record the initial setup for Chris to use", isCompleted: true)
        ]
    }
}
