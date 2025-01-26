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
    
    print("directory: \(directory)")
    print("newName: \(newName)")
    

    // Create a new URL with the updated name and the original extension
    let renamedURL = directory.appendingPathComponent(newName).appendingPathExtension(fileExtension)
    print("renamedURL: \(renamedURL)")

    do {
        let access = fileURL.startAccessingSecurityScopedResource()
        let folderAccess = fileURL.deletingLastPathComponent().startAccessingSecurityScopedResource()
        print("access? \(access) // folderAccess? \(folderAccess)")
        try FileManager.default.moveItem(at: fileURL, to: renamedURL)
    } catch let error as NSError {
        switch CocoaError.Code(rawValue: error.code) {
        case .fileWriteFileExists:
            print("File exists error")
        default:
            print("Other error")
        }
        throw error
    } catch {
        print("Non-NSError error")
    }
    print("will stop accessing security scoped resource")
    fileURL.stopAccessingSecurityScopedResource()
//    if directory.startAccessingSecurityScopedResource() {
//        defer { directory.stopAccessingSecurityScopedResource() }
//    } else {
//        print("Failed to obtain access to the security-scoped resource.")
//    }
}

/// ATM we use UTType.audio but could add specific audio formats later, if needed.
let supportedTypes: [UTType] = [UTType.audio]


/// Folder picker to give access to parent folder and all its files
struct FolderPicker: UIViewControllerRepresentable {
    // @EnvironmentObject private var bookmarkController: BookmarkController
    @Binding var folderPickerWasCancelled: Bool
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.folder])
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        print("updateUIViewController documentPicker")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FolderPicker
        var newName: String
        
        init(parent: FolderPicker, newName: String = "") {
            self.parent = parent
            self.newName = newName
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
        
        {
//            // save bookmark
//            urls.forEach { url in
//                // parent.bookmarkController.addBookmark(for: url)
//                print("picked folder", url)
//            }
            let url = urls.first!
            let access = url.startAccessingSecurityScopedResource()
            print("access \(access)")
            print("url \(url)")
            print("isFileURL \(url.isFileURL)")
            print("resolving symlinks \(url.resolvingSymlinksInPath())")
            let fm = FileManager.default
            do {
                let items = try fm.contentsOfDirectory(atPath: url.path)
                for item in items {
                    print("found \(item)")
                }
            } catch {
                
            }
            url.stopAccessingSecurityScopedResource()
            
            parent.folderPickerWasCancelled = false
        }
        
        func documentPickerWasCancelled(
            _ controller: UIDocumentPickerViewController)
        {
            print("folder picker was cancelled")
            parent.folderPickerWasCancelled = true
        }
    }
}

/// Document picker to rename
struct DocumentPicker: UIViewControllerRepresentable {
    @EnvironmentObject private var bookmarkController: BookmarkController
    @Binding var newName: String
    @Binding var wasSuccessful: Bool
    @Binding var pickedURLs: [URL]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        print("updateUIViewController documentPicker")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            do {
                try urls.forEach { url in
                    try renameFile(at: url, to: parent.newName)
                    parent.wasSuccessful = true
                    url.stopAccessingSecurityScopedResource()
                    print("stopped access for \(url)")
                }
            } catch let error as NSError {
                switch CocoaError.Code(rawValue: error.code) {
                case .fileWriteFileExists:
                    print("File exists error")
                    // send success signal so that it doesn't retry
                    parent.wasSuccessful = true
                default:
                    print("Other error")
                    parent.wasSuccessful = false
                    // elevate pickedURLs to retry automatically after failing
                    parent.pickedURLs = urls
                }
            }
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("documentPickerWasCancelled")
            parent.wasSuccessful = true
        }
    }
}
