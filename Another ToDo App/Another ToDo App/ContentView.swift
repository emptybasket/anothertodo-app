//
//  ContentView.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/20/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
             VStack {
                Text("Hello. world!")
                    .padding()
                    .navigationTitle("TODO App")
            }
             .sheet(isPresented: $isPresented, content: {
                 AddToDoListItemScreen()
             })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
