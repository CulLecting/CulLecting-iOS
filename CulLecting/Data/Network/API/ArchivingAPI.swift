//
//  ArchivingAPI.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import Foundation

import Alamofire


import Foundation
import Alamofire

enum ArchivingAPI: URLRequestConvertible {
    case uploadArchiving
    case uploadArchiveImg
    case fetchArchiving
    case fetchSingleTicket(id: String)
    case updateArchiving(id: String, dto: UpdateArchivingRequestDTO)
    case updateImage(id: String)
    case updateTemplate(id: String, template: String)
    case deleteArchiving(id: String)
    case getPreferenceCard

    var method: HTTPMethod {
        switch self {
        case .fetchArchiving, .fetchSingleTicket, .getPreferenceCard:
            return .get
        case .updateArchiving, .updateImage, .updateTemplate:
            return .patch
        case .deleteArchiving:
            return .delete
        case .uploadArchiving, .uploadArchiveImg:
            return .post
        }
    }

    var path: String {
        switch self {
        case .uploadArchiving:
            return "/archivings"
        case .uploadArchiveImg:
            return "/archivings/ios"
        case .fetchArchiving:
            return "/archivings"
        case .fetchSingleTicket(let id):
            return "/archivings/\(id)"
        case .updateArchiving(let id, _):
            return "/archivings/\(id)"
        case .updateImage(let id):
            return "/archivings/\(id)/image"
        case .updateTemplate(let id, _):
            return "/archivings/\(id)/template"
        case .deleteArchiving(let id):
            return "/archivings/\(id)"
        case .getPreferenceCard:
            return "/archivings/preference-card"
        }
    }

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            APIConstants.HeaderKey.authorization: "Bearer \(TokenStorage.shared.accessToken ?? "")"
        ]

        switch self {
        case .uploadArchiving, .uploadArchiveImg, .updateImage:
            headers.add(name: APIConstants.HeaderKey.contentType, value: "multipart/form-data")
        case .updateArchiving, .updateTemplate:
            headers.add(name: APIConstants.HeaderKey.contentType, value: APIConstants.HeaderValue.json)
        default:
            break
        }

        return headers
    }

    func asURLRequest() throws -> URLRequest {
        let url = try "\(APIConstants.baseURL)\(path)".asURL()
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers

        switch self {
        case .updateArchiving(_, let dto):
            request.httpBody = try? JSONEncoder().encode(dto)

        case .updateTemplate(_, let template):
            let body = ["template": template]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        case .uploadArchiving, .uploadArchiveImg, .updateImage:
            break

        default:
            break
        }

        return request
    }
}
