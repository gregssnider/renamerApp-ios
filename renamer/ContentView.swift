//
//  ContentView.swift
//  renamer
//
//  Created by Juan Martin on 22/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isDirectoryPickerPresented: Bool = false
    @State private var isFilePickerPresented: Bool = false
    @State private var newName: String = ""
    @State private var wasRenamed: Bool = false
    @State private var shouldShowPermissionsAlert: Bool = false
    @State private var shouldShowFolderPicker: Bool = false
    @State private var pickedURLs: [URL] = []
    @State private var folderPickerWasCancelled: Bool = false
    @EnvironmentObject var bookmarkController: BookmarkController
    
    
    var body: some View {
        VStack {
            TextField("Enter new name", text: $newName)
                .padding()
                .border(Color.black, width: 1)
                .background(.gray.opacity(0.2))
            Button("Show Directory picker") {
                isDirectoryPickerPresented.toggle()
            }
            .sheet(isPresented: $isDirectoryPickerPresented) {
                FolderPicker(folderPickerWasCancelled: $folderPickerWasCancelled)
            }
            
            Button("Show File picker") {
                isFilePickerPresented.toggle()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .foregroundStyle(.white)
            .sheet(isPresented: $isFilePickerPresented) {
                DocumentPicker(newName: $newName, wasSuccessful: $wasRenamed, pickedURLs: $pickedURLs)
                    .onDisappear {
                        if !wasRenamed {
                            shouldShowPermissionsAlert = true
                        }
                    }
            }
            .alert(isPresented: $shouldShowPermissionsAlert) {
                Alert(title: Text("We need folder access"),
                      message: Text("To continue please select the containing folder to give the app access to it."),
                      dismissButton: .default(Text("Select Folder")) {
                    shouldShowFolderPicker = true
                })
            }
            .sheet(isPresented: $shouldShowFolderPicker) {
                FolderPicker(folderPickerWasCancelled: $folderPickerWasCancelled)
                    .onDisappear {
                        if !wasRenamed && folderPickerWasCancelled && pickedURLs.count > 0 {
                            pickedURLs.forEach { url in
                                do {
                                    try renameFile(at: url, to: newName)
                                    print("ranamed \(url) to \(newName)")
                                    wasRenamed = true
                                } catch let error as NSError {
                                    print("renameError: \(error.localizedDescription)")
                                    if CocoaError.Code(rawValue: error.code) == .fileWriteFileExists {
                                        shouldShowPermissionsAlert = false
                                        wasRenamed = true // just to avoid alert loop
                                    } else {
                                        shouldShowPermissionsAlert = true
                                        wasRenamed = false
                                    }
                                }
                            }
                        }
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
