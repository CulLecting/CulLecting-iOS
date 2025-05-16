//
//  NetworkManager.swift
//  CulLecting
//
//  Created by 김승희 on 4/16/25.
//


import Foundation

import Alamofire
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    //MARK: - request with auto refresh
    //TODO: 서버에서 에러코드 분류해서 내려주는거로 변경되면 하드코딩 리팩토링해야함
    func request<T: Decodable>(_ urlRequest: URLRequestConvertible) -> Single<T> {
        return makeRequest(urlRequest)
            .catch { error -> Single<T> in
                if case NetworkError.serverMessage(let message) = error,
                   message.contains("토큰이 만료되었습니다") || message.contains("Authorization 헤더가 필요합니다.") {
                    return self.refreshAccessToken()
                        .flatMap { _ in self.makeRequest(urlRequest) }
                } else {
                    return .error(error)
                }
            }
    }
    
    func request<T: Decodable>(_ type: T.Type, _ urlRequest: URLRequestConvertible) -> Single<T> {
        return makeRequest(urlRequest)
    }
    
    private func makeRequest<T: Decodable>(_ urlRequest: URLRequestConvertible) -> Single<T> {
        return Single.create { single in
            AF.request(urlRequest)
                .responseDecodable(of: BaseResponse<T>.self) { response in
                    switch response.result {
                    case .success(let base):
                        if let data = base.data {
                            single(.success(data))
                        } else if T.self == EmptyDecodable.self {
                            single(.success(EmptyDecodable() as! T))
                        } else {
                            print("Response Data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")")
                            single(.failure(NetworkError.noData))
                        }
                    case .failure:
                        print("NetworkManager: Request failed")
                        print("URL: \(response.request?.url?.absoluteString ?? "No URL")")
                        print("Status Code: \(response.response?.statusCode ?? 0)")
                        print("Response Data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")")
                        
                        if let data = response.data,
                           let errorDTO = try? JSONDecoder().decode(ErrorResponseDTO.self, from: data) {
                            single(.failure(NetworkError.serverMessage(errorDTO.message)))
                        } else {
                            single(.failure(NetworkError.unknown))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    func requestWithoutData(_ urlRequest: URLRequestConvertible) -> Completable {
        return Completable.create { completable in
            AF.request(urlRequest)
                .responseDecodable(of: BaseResponse<EmptyDecodable>.self) { response in
                    switch response.result {
                    case .success:
                        completable(.completed)
                    case .failure:
                        print("NetworkManager: Request failed")
                        print("URL: \(response.request?.url?.absoluteString ?? "No URL")")
                        print("Status Code: \(response.response?.statusCode ?? 0)")
                        print("Response Data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")")
                        
                        if let data = response.data,
                           let errorDTO = try? JSONDecoder().decode(ErrorResponseDTO.self, from: data) {
                            completable(.error(NetworkError.serverMessage(errorDTO.message)))
                        } else {
                            completable(.error(NetworkError.unknown))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    // MARK: - Refresh Token
    private func refreshAccessToken() -> Single<Void> {
        print("AccessToken: \(TokenStorage.shared.accessToken ?? "nil")")
        print("RefreshToken: \(TokenStorage.shared.refreshToken ?? "nil")")

        return NetworkManager.shared.request(AuthAPI.refreshToken)
            .do(onSuccess: { (token: TokenDTO) in
                TokenStorage.shared.accessToken = token.accessToken
                TokenStorage.shared.refreshToken = token.refreshToken
            })
            .map { _ in () }
    }
    
    func uploadMultipart(
        to api: URLRequestConvertible,
        image: Data,
        parameters: [String: Any]?
    ) -> Completable {
        return Completable.create { completable in
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                    parameters?.forEach { key, value in
                        if let data = "\(value)".data(using: .utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                },
                with: api
            )
            .response { response in
                if let error = response.error {
                    if let data = response.data,
                       let errorDTO = try? JSONDecoder().decode(ErrorResponseDTO.self, from: data) {
                        completable(.error(NetworkError.serverMessage(errorDTO.message)))
                    } else {
                        completable(.error(error))
                    }
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadMultipartWithResponse<T: Decodable>(
        to api: URLRequestConvertible,
        image: Data,
        parameters: [String: Any]?,
        responseType: T.Type
    ) -> Single<T> {
        return Single.create { single in
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                    parameters?.forEach { key, value in
                        if let data = "\(value)".data(using: .utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                },
                with: api
            )
            .responseDecodable(of: BaseResponse<T>.self) { response in
                switch response.result {
                case .success(let base):
                    if let data = base.data {
                        single(.success(data))
                    } else {
                        print("❗ BaseResponse.data가 nil")
                        print("Raw Response: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "no data")")
                        single(.failure(NetworkError.noData))
                    }
                case .failure(let err):
                    print("❗ 디코딩 실패")
                    print("Error: \(err)")
                    if let data = response.data {
                        print("Raw Response: \(String(data: data, encoding: .utf8) ?? "no data")")
                    }
                    single(.failure(NetworkError.unknown))
                }
            }
            return Disposables.create()
        }
    }
}

struct EmptyDecodable: Decodable {}
