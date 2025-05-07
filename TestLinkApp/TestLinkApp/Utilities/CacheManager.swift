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

protocol ICacheManager: Sendable {
    func saveImage(_ data: Data, forKey key: String, type: CacheImageType) async
    func getImage(forKey key: String, type: CacheImageType) async -> Data?
    func urlImage(forKey key: String, type: CacheImageType) async -> URL
}

actor CacheManager {
    
    //MARK: Properties
    
    static let shared = CacheManager()
    
    //MARK: Private Properties
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    //MARK: Init

    private init() {
        self.cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        for type in [CacheImageType.preview, .full] {
            let folder = cacheDirectory.appendingPathComponent(type.folderName)
            if !fileManager.fileExists(atPath: folder.path) {
                try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
        }
    }

}

extension CacheManager: ICacheManager {
    
    //MARK: Functions
    
    func saveImage(_ data: Data, forKey key: String, type: CacheImageType) async {
        let fileURL = await urlImage(forKey: key, type: type)
        do {
            try data.write(to: fileURL)
        } catch {
            print("Failed to write cache for \(type): \(error)")
        }
    }

    func getImage(forKey key: String, type: CacheImageType) async -> Data? {
        let fileURL = await urlImage(forKey: key, type: type)
        return try? Data(contentsOf: fileURL)
    }

    func urlImage(forKey key: String, type: CacheImageType) async -> URL {
        let folder = cacheDirectory.appendingPathComponent(type.folderName)
        return folder.appendingPathComponent(key.sha256())
    }
    
}
