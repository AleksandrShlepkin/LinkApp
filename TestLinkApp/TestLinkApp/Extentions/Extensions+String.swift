//
//  Extensions+String.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import Foundation
import CryptoKit

extension String {
    func sha256() -> String {
        let hash = SHA256.hash(data: Data(self.utf8))
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
