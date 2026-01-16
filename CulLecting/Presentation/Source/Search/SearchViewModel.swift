//
//  SearchViewModel.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import UIKit

import RxSwift
import RxCocoa


final class SearchViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private let useCase: SearchUseCase
    private let disposeBag = DisposeBag()
    
    
    init(useCase: SearchUseCase) {
        self.useCase = useCase
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
    }
    
    //    func transform(input: Input) -> Output {
    //
    //    }
    
    private let session: URLSession
    
    let culturalSubject = BehaviorSubject(value: [CulturalNameDTO]([]))
    let culturalDetailSubject = PublishSubject<CulturalDetailDTO>()
    
    private func createFilterURL(filter: FilterRequestDTO) -> URL? {
        var components = URLComponents(string: "https://cullecting.site/cultural/filter")
            components?.queryItems = []

            if let codeName = filter.codeName, !codeName.isEmpty {
                components?.queryItems?.append(URLQueryItem(name: "codeName", value: codeName))
            }

            if let guName = filter.guName, !guName.isEmpty {
                components?.queryItems?.append(URLQueryItem(name: "guName", value: guName))
            }

            if let themeCode = filter.themeCode, !themeCode.isEmpty {
                components?.queryItems?.append(URLQueryItem(name: "themeCode", value: themeCode))
            }

            if let isFree = filter.isFree {
                components?.queryItems?.append(URLQueryItem(name: "isFree", value: isFree ? "true" : "false"))
            }

            return components?.url
    }
    
    func findDataFromKeyword(keyword: String) {
        guard let url = URL(string: "https://cullecting.site/cultural/search?keyword=\(keyword)") else {
            return
        }
        fetch(url: url).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] (result: BaseResponse<[CulturalNameDTO]>) in
            guard let self = self else { return }
            print("검색")
            guard let data = result.data else { return }
            self.culturalSubject.onNext(data)
        }, onFailure: { error in
            if (error as NSError).code == 404 {
                self.culturalSubject.onNext([])
            } else {
                self.culturalSubject.onError(error)
            }
            print("Error: \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }
    
    func findDataFromFilter(filter: FilterRequestDTO) {
        guard let url = createFilterURL(filter: filter) else {
            return
        }
        fetch(url: url).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] (result: BaseResponse<[CulturalNameDTO]>) in
            guard let self = self else { return }
            print("검색")
            guard let data = result.data else { return }
            self.culturalSubject.onNext(data)
        }, onFailure: { error in
            if (error as NSError).code == 404 {
                self.culturalSubject.onNext([])
            } else {
                self.culturalSubject.onError(error)
            }
            print("Error: \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }
    
    func findDataFromDate(date: String) {
        guard let url = URL(string: "https://cullecting.site/cultural/date?date=\(date)") else {
            return
        }
        fetch(url: url).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] (result: BaseResponse<[CulturalNameDTO]>) in
            guard let self = self else { return }
            print("검색")
            guard let data = result.data else { return }
            self.culturalSubject.onNext(data)
        }, onFailure: { error in
            if (error as NSError).code == 404 {
                self.culturalSubject.onNext([])
            } else {
                self.culturalSubject.onError(error)
            }
            print("Error: \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }
    
    func findDetailData(id: Int) {
        guard let url = URL(string: "https://cullecting.site/cultural/\(id)") else {
            return
        }
        fetch(url: url).observe(on: MainScheduler.instance).subscribe(onSuccess: { [weak self] (result: BaseResponse<CulturalDetailDTO>) in
            guard let self = self else { return }
            print("상세")
            guard let data = result.data else { return }
            self.culturalDetailSubject.onNext(data)
        })
        .disposed(by: disposeBag)
    }
    
    func fetch<T: Decodable>(url: URL) -> Single<T> {
        return Single.create { observer in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                guard let data = data else {
                    return observer(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                }
                
                guard let response = response as? HTTPURLResponse else {
                    return observer(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                }
                
                if !(200..<300).contains(response.statusCode) {
                    if response.statusCode == 404 {
                        do {
                            let decodeData = try JSONDecoder().decode(ErrorResponseDTO.self, from: data)
                            observer(.failure(NSError(domain: "404NotFound", code: 404)))
                        } catch {
                            observer(.failure(error))
                        }

                    }
                    return observer(.failure(NSError(domain: "", code: response.statusCode, userInfo: nil)))
                }
                
                do {
                    let decodeData = try JSONDecoder().decode(T.self, from: data)
                    observer(.success(decodeData))
                } catch {
                    observer(.failure(error))
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}

struct FilterRequestDTO {
    
    init(codeName: String?, guName: String?, themeCode: String?, isFree: Bool?) {
        self.codeName = codeName
        self.guName = guName
        self.themeCode = themeCode
        self.isFree = isFree
    }
    let codeName: String?
    let guName: String?
    let themeCode: String?
    let isFree: Bool?
}
