//
//  NetworkManager.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import Foundation

final class NetworkManager {
    
    func fetchImageLinks() async throws -> [URL] {
        guard let url = URL(string: "https://it-link.ru/test/images.txt") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let text = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }

        let candidates = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter {  $0.hasPrefix("https://") }
            .compactMap { URL(string: $0) }


        var imageURLs: [URL] = []

        for url in candidates {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "HEAD"
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse,
                   let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
                   contentType.starts(with: "image/") {
                    imageURLs.append(url)
                }
               
            } catch {
                print("⚠️ Error HEAD request : \(url) — \(error.localizedDescription)")
                continue
            }
        }

        return imageURLs
    }

}
