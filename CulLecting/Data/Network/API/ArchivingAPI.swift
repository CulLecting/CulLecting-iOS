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
    case uploadArchiving(dto: UploadArchivingRequestDTO)
    case uploadArchiveImg(image: Data)
    case fetchArchiving
    case fetchSingleTicket(id: String)
    case updateArchiving(dto: UpdateArchivingRequestDTO)
    case updateImage(dto: UpdateImageRequestDTO)
    case updateTemplate(dto: UpdateTemplateRequestDTO)
    case deleteArchiving(id: String)
    case getPreferenceCard

    var method: HTTPMethod {
        switch self {
        case .fetchArchiving, .getPreferenceCard:
            return .get
        default:
            return .post
        }
    }

    var path: String {
        switch self {
        case .uploadArchiving: return "/archiving/upload"
        case .uploadArchiveImg: return "/archiving/iOS/upload"
        case .fetchArchiving: return "/archiving/findarchiving"
        case .fetchSingleTicket: return "/archiving/find"
        case .updateArchiving: return "/archiving/update"
        case .updateImage: return "/archiving/updateimage"
        case .updateTemplate: return "/archiving/updatetemplate"
        case .deleteArchiving: return "/archiving/deletearchiving"
        case .getPreferenceCard: return "/archiving/get-preference-card"
        }
    }

    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Authorization": "Bearer \(TokenStorage.shared.accessToken ?? "")"
        ]

        switch self {
        case .uploadArchiving, .uploadArchiveImg, .updateImage:
            headers.add(name: "Content-Type", value: "multipart/form-data")
        case .updateArchiving, .updateTemplate, .deleteArchiving:
            headers.add(name: "Content-Type", value: "application/json")
        case .fetchArchiving, .fetchSingleTicket, .getPreferenceCard:
            break
        }
        return headers
    }

    var parameters: Parameters? {
        switch self {
        case .fetchSingleTicket(let id):
            return ["id": id]
        case .deleteArchiving(let id):
            return ["id": id]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .uploadArchiving(let dto):
            return try? JSONEncoder().encode(dto)
        case .updateArchiving(let dto):
            return try? JSONEncoder().encode(dto)
        case .updateTemplate(let dto):
            return try? JSONEncoder().encode(dto)
        case .updateImage(let dto):
            return try? JSONEncoder().encode(dto)
        default:
            return nil
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try "\(APIConstants.baseURL)\(path)".asURL()
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers

        if let params = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        } else if let body = body {
            request.httpBody = body
        }

        return request
    }
}
