// APIKeyManager.swift
// ForexMindGuard – Utilities/Helpers
//
// Secure API key storage and retrieval using iOS Keychain.
// Keys are NEVER stored in UserDefaults or hardcoded.

import Foundation
import Security

// MARK: - API key identifiers
enum APIKeyIdentifier: String, CaseIterable {
    case openAI       = "com.forexmindguard.apikey.openai"
    case alphaVantage = "com.forexmindguard.apikey.alphavantage"
    case traderMade   = "com.forexmindguard.apikey.tradermade"
    case finage       = "com.forexmindguard.apikey.finage"
    case newsAPI      = "com.forexmindguard.apikey.newsapi"
}

// MARK: - APIKeyManager
final class APIKeyManager {
    static let shared = APIKeyManager()
    private init() {}

    // MARK: - Store key
    /// Stores an API key securely in the Keychain.
    @discardableResult
    func store(key: String, for identifier: APIKeyIdentifier) -> Bool {
        let data = Data(key.utf8)
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: identifier.rawValue,
            kSecValueData as String:   data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        // Delete existing before adding
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Retrieve key
    /// Retrieves an API key from the Keychain. Returns nil if not found.
    func key(for identifier: APIKeyIdentifier) -> String? {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassGenericPassword,
            kSecAttrAccount as String:      identifier.rawValue,
            kSecReturnData as String:       true,
            kSecMatchLimit as String:       kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete key
    @discardableResult
    func delete(identifier: APIKeyIdentifier) -> Bool {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: identifier.rawValue
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    // MARK: - Check if key is set
    func hasKey(for identifier: APIKeyIdentifier) -> Bool {
        key(for: identifier) != nil
    }

    // MARK: - Validation
    var missingKeys: [APIKeyIdentifier] {
        APIKeyIdentifier.allCases.filter { !hasKey(for: $0) }
    }

    var allKeysConfigured: Bool { missingKeys.isEmpty }
}
