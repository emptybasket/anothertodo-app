//
//  AddToDoListItemScreen.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/21/23.
//

import SwiftUI
import SwiftData

struct AddToDoListItemScreen: View {
    
    @State private var name = ""
    @State private var noteDiscription = ""
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !name.isEmptyOrWithWhiteSpace && !noteDiscription.isEmptyOrWithWhiteSpace
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Title", text: $name)
                TextField("Enter your notes", text: $noteDiscription)
                Button("Save") {
                    let todo = ToDo(name: name, note: noteDiscription)
                    context.insert(todo)
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    dismiss()
                }.disabled(!isFormValid)
            }
            .navigationTitle("Add todo item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddToDoListItemScreen()
        .modelContainer(for: [ToDo.self])
}
