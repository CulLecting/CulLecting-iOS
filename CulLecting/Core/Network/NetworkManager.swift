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

    // MARK: - 데이터 있는 요청
    func request<T: Decodable>(
        _ urlRequest: URLRequestConvertible
    ) -> Single<T> {
        return Single.create { single in
            AF.request(urlRequest)
                .validate()
                .responseDecodable(of: BaseResponse<T>.self) { response in
                    switch response.result {
                    case .success(let base):
                        if let data = base.data {
                            single(.success(data))
                        } else {
                            single(.failure(NetworkError.decodingError))
                        }

                    case .failure:
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

    // MARK: - 데이터 없는 요청 (Void 처리)
    func requestWithoutData(
        _ urlRequest: URLRequestConvertible
    ) -> Completable {
        return Completable.create { completable in
            AF.request(urlRequest)
                .validate()
                .responseDecodable(of: BaseResponse<EmptyDecodable>.self) { response in
                    switch response.result {
                    case .success:
                        completable(.completed)

                    case .failure:
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
}

private struct EmptyDecodable: Decodable {}
