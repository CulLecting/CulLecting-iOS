//
//  OnboardingOptionEntity.swift
//  CulLecting
//
//  Created by 김승희 on 4/12/25.
//


enum Location: String, CaseIterable {
    case gangnam = "강남구"
    case gangdong = "강동구"
    case gangbuk = "강북구"
    case gangseo = "강서구"
    case gwanak = "관악구"
    case gwangjin = "광진구"
    case guro = "구로구"
    case geumcheon = "금천구"
    case nowon = "노원구"
    case dobong = "도봉구"
    case dongdaemun = "동대문구"
    case dongjak = "동작구"
    case mapo = "마포구"
    case seodaemun = "서대문구"
    case seocho = "서초구"
    case seongdong = "성동구"
    case seongbuk = "성북구"
    case songpa = "송파구"
    case yangcheon = "양천구"
    case yeongdeungpo = "영등포구"
    case yongsan = "용산구"
    case eunpyung = "은평구"
    case jongno = "종로구"
    case jung = "중구"
    case jungnang = "중랑구"
}

enum Category: String, CaseIterable {
    case exhibitionAndArt = "전시/미술"
    case festival = "축제"
    case play = "연극"
    case musicalAndOpera = "뮤지컬/오페라"
    case dance = "무용"
    case gugak = "국악"
    case concert = "콘서트"
    case classical = "클래식"
    case movie = "영화"
    case educationAndExperience = "교육/체험"
}

struct OnboardingOption<T: Hashable> {
    let value: T
    var isSelected: Bool
    
    public init(value: T, isSelected: Bool = false) {
        self.value = value
        self.isSelected = isSelected
    }
}
