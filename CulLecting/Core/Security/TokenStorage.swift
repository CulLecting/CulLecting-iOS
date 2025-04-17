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
    static let shared = TokenStorage()
    //싱글톤으로 선언했기 때문에, 외부에서 새로운 객체를 만들지 못하도록 막음.
    private init() {}
    
    enum Key: String {
        case accessToken
        case refreshToken
    }
    
    //MARK: 토큰별 접근 편의 프로퍼티
    var accessToken: String? { load(key: .accessToken) }
    var refreshToken: String? { load(key: .refreshToken) }
    
    //MARK: 메서드
    func save(value: String, key: Key) {
        //keychain에서는 딕셔너리로 데이터 값과 속성을 같이 지정해서 요청함.
        let query: [String: Any] = [
            //kSecClassGenericPassword: 비밀번호, 토큰 등 일반 문자열을 저장함
            kSecClass as String: kSecClassGenericPassword,
            //kSecAttrAccount: 이 데이터의 키 이름. 여기서는 accessToken, refreshToken
            kSecAttrAccount as String: key.rawValue,
            //kSecValueData: 실제 저장할 데이터 본문으로, String -> Data로 바꿔서 넣어야 한다.
            kSecValueData as String: Data(value.utf8)
        ]
        // 기존 값 삭제 후 저장
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            //kSecMatchLimit: 조건에 맞는 항목이 여러 개일 때, 몇 개를 가져올지 정한다. 여기서 kSecMatchLimitOne: 하나만 가져옴.
            kSecMatchLimit as String: kSecMatchLimitOne,
            //kSecReturnData: 불러올 때만 쓰는 키로, 저장된 데이터를 가져올지 말지 지정.
            kSecReturnData as String: true
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let string = String(data: data, encoding: .utf8)
        else { return nil }
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
