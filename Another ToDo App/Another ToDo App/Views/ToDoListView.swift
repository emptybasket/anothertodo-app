//
//  ToDoListView.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/21/23.
//

import SwiftUI
import SwiftData

struct ToDoListView: View {
    
    let todos: [ToDo]
    @Environment(\.modelContext) private var context
    
    private func deleteTodo(indexSet: IndexSet) {
        indexSet.forEach { index in
            let doto = todos[index]
            context.delete(doto)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(todos, id: \.id) { todo in
                NavigationLink(value: todo) {
                    VStack(alignment: .leading) {
                        Text(todo.name)
                            .font(.title3)
                        Text(todo.note)
                            .font(.caption)
                    }
                }
            }.onDelete(perform: deleteTodo)
        }.navigationDestination(for: ToDo.self) { todo in
            ToDoDetailScreen(todo: todo)
        }
    }
}
