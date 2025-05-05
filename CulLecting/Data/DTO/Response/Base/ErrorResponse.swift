//
//  ErrorResponse.swift
//  CulLecting
//
//  Created by 김승희 on 4/16/25.
//


struct ErrorResponseDTO: Decodable {
    let message: String

    enum CodingKeys: String, CodingKey {
        case message
        case error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let msg = try? container.decode(String.self, forKey: .message) {
            self.message = msg
        } else if let err = try? container.decode(String.self, forKey: .error) {
            self.message = err
        } else {
            self.message = "알 수 없는 에러"
        }
    }
}
