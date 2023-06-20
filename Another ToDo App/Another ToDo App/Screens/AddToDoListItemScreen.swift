//
//  AddToDoListItemScreen.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/21/23.
//

import SwiftUI

struct AddToDoListItemScreen: View {
    
    @State private var title = ""
    @State private var noteDiscription = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Title", text: $title)
                TextField("Enter your notes", text: $noteDiscription)
                
                Button {
                    dismiss()
                } label: {
                    Text("Save")
                }
                
            }
            .navigationTitle("Add todo item")
        }
    }
}

#Preview {
    AddToDoListItemScreen()
}
