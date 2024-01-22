//
//  DocumentPicker.swift
//  METASOUND
//
//  Created by Juan Martin on 13/07/2023.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices


/// Rename selected file from browser
func renameFile(at fileURL: URL, to newName: String) throws {
    let fileExtension = fileURL.pathExtension
    let directory = fileURL.deletingLastPathComponent()

    // Create a new URL with the updated name and the original extension
    let renamedURL = directory.appendingPathComponent(newName).appendingPathExtension(fileExtension)

    try FileManager.default.moveItem(at: fileURL, to: renamedURL)
}

/// ATM we use UTType.audio but could add specific audio formats later, if needed.
let supportedTypes: [UTType] = [UTType.audio]

struct BrowserView: View {
    
    @State private var fileBrowserIsShown = false
    @Binding var newName: String
    
    var body: some View {
        DocumentPicker(newName: $newName)
            .environmentObject(BookmarkController())
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var newName: String
    @EnvironmentObject private var bookmarkController: BookmarkController
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        print("updateUIViewController documentPicker")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, newName)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        var newName: String
        
        init(_ parent: DocumentPicker, _ newName: String = "") {
            self.parent = parent
            self.newName = newName
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // save bookmark
            print("documentPicker \(urls[0])")
            parent.bookmarkController.addBookmark(for: urls[0])
            
            // Rename the file
            var error: NSError?
            
            NSFileCoordinator().coordinate(readingItemAt: urls[0], options: [], error: &error) { coordinatedURL in
                do {
                    //                let data = try Data(contentsOf: newURL)
                    print("urls[0]: \(urls[0])")
                    print("coordinatedURL: \(coordinatedURL)")
                    print("renamedURL: \(newName)")
                    try renameFile(at: coordinatedURL, to: newName)
                } catch  {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
