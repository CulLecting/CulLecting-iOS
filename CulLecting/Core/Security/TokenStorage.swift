//
//  TokenStorage.swift
//  CulLecting
//
//  Created by 김승희 on 4/16/25.
//


import Foundation
import Security


final class TokenStorage {
    //싱글톤으로 선언
    // 외부에서 가져다 쓸 때, TokenStorage의 내부가 Keychain인지 뭔지 신경 쓸 필요 없다.
    static let shared = TokenStorage()
    //싱글톤으로 선언했기 때문에, 외부에서 새로운 객체를 만들지 못하도록 막음.
    private init() {}
    
    enum Key: String {
        case accessToken
        case refreshToken
    }
    
    //MARK: 토큰별 접근 편의 프로퍼티
    var accessToken: String? {
        get { load(key: .accessToken) }
        set {
            if let value = newValue {
                save(value: value, key: .accessToken)
            } else {
                delete(key: .accessToken)
            }
        }
    }
    
    var refreshToken: String? {
        get { load(key: .refreshToken) }
        set {
            if let value = newValue {
                save(value: value, key: .refreshToken)
            } else {
                delete(key: .refreshToken)
            }
        }
    }
    
    //MARK: 메서드
    func save(value: String, key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: Data(value.utf8)
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
    }

    
    func load(key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let string = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return string
    }

    
    func delete(key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    func clearAll() {
        delete(key: .accessToken)
        delete(key: .refreshToken)
    }
}
