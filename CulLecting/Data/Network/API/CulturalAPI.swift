//
//  CulturalAPI.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import Foundation

import Alamofire


enum CulturalAPI: URLRequestConvertible {
    case findCulturalImage(keyword: String)
    case recommendCultural
    case latestCultural
    case findCulturalFromDate(date: String)
    case culturalDetail(id: Int)
    case findCulturalName(keyword: String)
    case culturalFilter(codeName: String?, guName: String?, themeCode: String?, isFree: Bool?)

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        switch self {
        case .findCulturalImage:
            return "/cultural/images"
        case .recommendCultural:
            return "/cultural/recommendations"
        case .latestCultural:
            return "/cultural/latest"
        case .findCulturalFromDate:
            return "/cultural/date"
        case .culturalDetail(let id):
            return "/cultural/\(id)"
        case .findCulturalName:
            return "/cultural/search"
        case .culturalFilter:
            return "/cultural/filter"
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .findCulturalImage(keyword),
             let .findCulturalName(keyword):
            return ["keyword": keyword]

        case let .findCulturalFromDate(date):
            return ["date": date]

        case .culturalDetail:
            return nil

        case let .culturalFilter(codeName, guName, themeCode, isFree):
            var params: Parameters = [:]
            if let codeName = codeName { params["codeName"] = codeName }
            if let guName = guName { params["guName"] = guName }
            if let themeCode = themeCode { params["themeCode"] = themeCode }
            if let isFree = isFree { params["isFree"] = isFree }
            return params

        case .recommendCultural, .latestCultural:
            return nil
        }
    }

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            APIConstants.HeaderKey.contentType: APIConstants.HeaderValue.json
        ]

        switch self {
        case .recommendCultural:
            if let accessToken = TokenStorage.shared.accessToken {
                headers.add(name: APIConstants.HeaderKey.authorization, value: "Bearer \(accessToken)")
            }
        default:
            break
        }

        return headers
    }

    func asURLRequest() throws -> URLRequest {
        let url = try (APIConstants.baseURL + path).asURL()
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers

        if let parameters = parameters {
            request = try URLEncoding.default.encode(request, with: parameters)
        }

        return request
    }
}
