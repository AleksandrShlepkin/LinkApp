//
//  CacheManager.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//
import Foundation
import UIKit

enum CacheImageType {
    case preview
    case full

    var folderName: String {
        switch self {
        case .preview: return "preview"
        case .full: return "full"
        }
    }
}

final class CacheManager {
    
    //MARK: Properties
    
    static let shared = CacheManager()
    
    //MARK: Private Properties
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    //MARK: Init

    private init() {
        self.cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        createSubfolders()
    }

    //MARK: Functions
    
    func save(_ data: Data, forKey key: String, type: CacheImageType) {
        let fileURL = url(forKey: key, type: type) ?? URL(string: "")
        do {
            try data.write(to: fileURL!)
        } catch {
            print("Failed to write cache for \(type): \(error)")
        }
    }

    func get(forKey key: String, type: CacheImageType) -> Data? {
        let fileURL = url(forKey: key, type: type) ?? URL(string: "")
        return try? Data(contentsOf: fileURL!)
    }

    func url(forKey key: String, type: CacheImageType) -> URL? {
        let folder = cacheDirectory.appendingPathComponent(type.folderName)
        return folder.appendingPathComponent(key.sha256())
    }
    
    //MARK: Private functions
    
    private func createSubfolders() {
        for type in [CacheImageType.preview, .full] {
            let folder = cacheDirectory.appendingPathComponent(type.folderName)
            if !fileManager.fileExists(atPath: folder.path) {
                try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
        }
    }
}
