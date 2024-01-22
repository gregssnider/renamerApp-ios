//
//  BookmarkController.swift
//  METASOUND
//
//  Created by Juan Martin on 17/01/2024.
//

// Save bookmark for accessing directory. See https://developer.apple.com/documentation/uikit/view_controllers/providing_access_to_directories#3331285 and https://stackoverflow.com/questions/70750276/how-to-enable-files-and-folders-permission-on-ios

import SwiftUI
import MobileCoreServices

class BookmarkController: ObservableObject {
    @Published var urls: [URL] = []
    
    init() {
        loadAllBookmarks()
    }
    
    func addBookmark(for url: URL) {
        let parentURL = url.deletingLastPathComponent()
        print("adding bookmark for \(parentURL)")
        do {
            guard parentURL.startAccessingSecurityScopedResource() else {
                print("Failed to obtain access to the security-scoped resource.")
                return
            }
            
            defer { parentURL.stopAccessingSecurityScopedResource() }
            
            let bookmarkData = try parentURL.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil)
            
            let uuid = UUID().uuidString
            try bookmarkData.write(to: getAppSandboxDir().appendingPathComponent(uuid))
            
            urls.append(parentURL)
        } catch {
            print("Error Adding Bookmark: \(error.localizedDescription)")
        }
    }
    
    func loadAllBookmarks() {
        // Get all the bookmark files
        let files = try? FileManager.default.contentsOfDirectory(at: getAppSandboxDir(), includingPropertiesForKeys: nil)
        // Map over the bookmark files
        self.urls = files?.compactMap { file in
            do {
                let bookmarkData = try Data(contentsOf: file)
                var isStale = false
                // Get the URL from each bookmark
                let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                
                guard !isStale else {
                    // Handle stale bookmarks
                    return nil
                }
                print("loaded bookmark: \(url)")
                // Return URL
                return url
            } catch {
                print("Error Loading Bookmark: \(error.localizedDescription)")
                return nil
            }
        } ?? []
    }
    
    private func getAppSandboxDir() -> URL {
        // TODO see 0 index
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
