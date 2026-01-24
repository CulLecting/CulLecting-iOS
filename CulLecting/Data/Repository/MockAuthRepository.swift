//
//  MockAuthRepository.swift
//  CulLecting
//
//  Mock repository for testing authentication in simulator
//

import Foundation
import RxSwift

public final class MockAuthRepository: AuthRepositoryProtocol {

    // MARK: - Mock Credentials
    private let mockEmail = "test"
    private let mockPassword = "1234"

    // MARK: - Mock User State
    private var isLoggedIn = false
    private var mockAccessToken = "mock_access_token_\(UUID().uuidString)"
    private var mockRefreshToken = "mock_refresh_token_\(UUID().uuidString)"

    // MARK: - Mock User Data
    private let mockUser = UserEntity(
        id: "mock_user_001",
        email: "test@mock.com",
        nickName: "TestUser",
        location: ["서울"],
        category: ["전시/미술", "공연"]
    )

    public init() {}

    // MARK: - AuthRepositoryProtocol Implementation

    public func login(email: String, password: String) -> Single<TokenDTO> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(MockAuthError.unknown))
                return Disposables.create()
            }

            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if email == self.mockEmail && password == self.mockPassword {
                    self.isLoggedIn = true
                    let token = TokenDTO(
                        accessToken: self.mockAccessToken,
                        refreshToken: self.mockRefreshToken
                    )
                    print("[MockAuth] Login successful for user: \(email)")
                    single(.success(token))
                } else {
                    print("[MockAuth] Login failed - Invalid credentials")
                    single(.failure(MockAuthError.invalidCredentials))
                }
            }
            return Disposables.create()
        }
    }

    public func signup(email: String, password: String, nickname: String, token: String) -> Completable {
        return Completable.create { completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("[MockAuth] Signup successful for: \(email)")
                completable(.completed)
            }
            return Disposables.create()
        }
    }

    public func fetchUserInfo() -> Single<UserEntity> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(MockAuthError.unknown))
                return Disposables.create()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.isLoggedIn || TokenStorage.shared.accessToken != nil {
                    print("[MockAuth] Fetched user info: \(self.mockUser.nickName)")
                    single(.success(self.mockUser))
                } else {
                    print("[MockAuth] Fetch user failed - Not logged in")
                    single(.failure(MockAuthError.notLoggedIn))
                }
            }
            return Disposables.create()
        }
    }

    public func refreshToken() -> Single<TokenDTO> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(MockAuthError.unknown))
                return Disposables.create()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mockAccessToken = "mock_access_token_\(UUID().uuidString)"
                let token = TokenDTO(
                    accessToken: self.mockAccessToken,
                    refreshToken: self.mockRefreshToken
                )
                print("[MockAuth] Token refreshed")
                single(.success(token))
            }
            return Disposables.create()
        }
    }

    public func sendVerificationCode(email: String) -> Completable {
        return Completable.create { completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("[MockAuth] Verification code sent to: \(email)")
                completable(.completed)
            }
            return Disposables.create()
        }
    }

    public func verifyCode(email: String, code: String) -> Single<String> {
        return Single.create { single in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Accept any 6-digit code for testing
                if code.count == 6 {
                    print("[MockAuth] Code verified for: \(email)")
                    single(.success("mock_verification_token"))
                } else {
                    single(.failure(MockAuthError.invalidCode))
                }
            }
            return Disposables.create()
        }
    }

    public func resetPassword(email: String) -> Completable {
        return Completable.create { completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("[MockAuth] Password reset email sent to: \(email)")
                completable(.completed)
            }
            return Disposables.create()
        }
    }

    public func confirmResetPassword(email: String, newPassword: String, token: String) -> Completable {
        return Completable.create { completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("[MockAuth] Password reset confirmed for: \(email)")
                completable(.completed)
            }
            return Disposables.create()
        }
    }

    public func changePassword(before: String, new: String) -> Completable {
        return Completable.create { completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("[MockAuth] Password changed successfully")
                completable(.completed)
            }
            return Disposables.create()
        }
    }

    public func logout() -> Completable {
        return Completable.create { [weak self] completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.isLoggedIn = false
                print("[MockAuth] Logged out successfully")
                completable(.completed)
            }
            return Disposables.create()
        }
    }

    public func deleteAccount() -> Completable {
        return Completable.create { [weak self] completable in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.isLoggedIn = false
                print("[MockAuth] Account deleted successfully")
                completable(.completed)
            }
            return Disposables.create()
        }
    }
}

// MARK: - Mock Auth Errors
public enum MockAuthError: LocalizedError {
    case invalidCredentials
    case notLoggedIn
    case invalidCode
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Use test/1234"
        case .notLoggedIn:
            return "User is not logged in"
        case .invalidCode:
            return "Invalid verification code"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
