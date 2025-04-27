//
//  ArchivingAPI.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//

import Foundation

import Alamofire


enum ArchivingAPI: URLRequestConvertible {
    case uploadArchiving(image: Data, title: String, description: String, date: String, category: String, template: String)
    case fetchArchiving
    case updateArchiving(id: String, title: String, description: String, date: String, category: String)
    case updateImage(id: String, image: Data)
    case updateTemplate(id: String, template: String)
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
        case .fetchArchiving: return "/archiving/findarchiving"
        case .updateArchiving: return "/archiving/update"
        case .updateImage: return "/archiving/updateimage"
        case .updateTemplate: return "/archiving/updatetemplate"
        case .deleteArchiving: return "/archiving/deletearchiving"
        case .getPreferenceCard: return "/archiving/get-preference-card"
        }
    }

    var headers: HTTPHeaders {
        var header: HTTPHeaders = [
            "Authorization": "Bearer \(TokenStorage.shared.accessToken ?? "")"
        ]
        switch self {
        case .uploadArchiving, .updateImage:
            header.add(name: "Content-Type", value: "multipart/form-data")
        case .updateArchiving, .updateTemplate, .deleteArchiving, .getPreferenceCard:
            header.add(name: "Content-Type", value: "application/json")
        case .fetchArchiving:
            break
        }
        return header
    }

    var multipartFormData: MultipartFormData? {
        switch self {
        case let .uploadArchiving(image, title, description, date, category, template):
            let formData = MultipartFormData()
            formData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            formData.append(Data(title.utf8), withName: "title")
            formData.append(Data(description.utf8), withName: "description")
            formData.append(Data(date.utf8), withName: "date")
            formData.append(Data(category.utf8), withName: "category")
            formData.append(Data(template.utf8), withName: "template")
            return formData

        case let .updateImage(id, image):
            let formData = MultipartFormData()
            formData.append(Data(id.utf8), withName: "id")
            formData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            return formData

        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case let .updateArchiving(id, title, desc, date, category):
            let body = [
                "id": id,
                "title": title,
                "description": desc,
                "date": date,
                "category": category
            ]
            return try? JSONSerialization.data(withJSONObject: body)

        case let .updateTemplate(id, template):
            let body = [
                "id": id,
                "template": template
            ]
            return try? JSONSerialization.data(withJSONObject: body)

        case let .deleteArchiving(id):
            let body = ["id": id]
            return try? JSONSerialization.data(withJSONObject: body)

        case .getPreferenceCard:
            return try? JSONSerialization.data(withJSONObject: [:])

        default:
            return nil
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try "\(APIConstants.baseURL)\(path)".asURL()
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers

        if let multipart = multipartFormData {
            return try Alamofire.URLEncoding.default.encode(request, with: nil)
        } else if let body = body {
            request.httpBody = body
        }
        return request
    }
}
