//
//  ContentView.swift
//  renamer
//
//  Created by Juan Martin on 22/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isFilePickerPresented: Bool = false
    @State private var newName: String = ""
    @EnvironmentObject var bookmarkController: BookmarkController


    var body: some View {
        VStack {
            TextField("Enter new name", text: $newName)
                .padding()
                .border(Color.black, width: 1)
                .background(.gray.opacity(0.2))
            Button("Show document picker") {
                isFilePickerPresented.toggle()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .foregroundStyle(.white)
            .sheet(isPresented: $isFilePickerPresented, content: {
                DocumentPicker(newName: $newName)
            })
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
