//
//  MockData.swift
//  CulLecting
//
//  Created for development and testing purposes
//

import Foundation

// MARK: - Mock Data for Development
extension Ticket {
    
    static let mockTickets: [Ticket] = (1...50).map { index in
        Ticket(
            id: "\(index)",
            title: "문화 티켓 \(index)",
            description: "캐러셀 테스트용 더미 데이터",
            date: "2025-06-01",
            imageURL: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600&h=400&fit=crop",
            category: "전시/공연",
            template: .basic,
            averageColorHex: "#8B7355"
        )
    }

//    static let mockTickets: [Ticket] = [
//        Ticket(
//            id: "1",
//            title: "예술의전당 오페라 <라 보엠>",
//            description: "이탈리아 오페라의 대표작",
//            date: "2025-01-15",
//            imageURL: "https://images.unsplash.com/photo-1580809361436-42a7ec204889?w=600&h=400&fit=crop",
//            category: "공연/오페라",
//            template: .floral,
//            averageColorHex: "#8B7355"
//        ),
//        Ticket(
//            id: "2",
//            title: "뮤지컬 <위키드>",
//            description: "브로드웨이 대표 뮤지컬",
//            date: "2025-02-01",
//            imageURL: "https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=400&h=600&fit=crop",
//            category: "뮤지컬",
//            template: .cloud,
//            averageColorHex: "#4A90E2"
//        ),
//        Ticket(
//            id: "3",
//            title: "국립현대미술관 특별전",
//            description: "현대 미술의 흐름을 조망하다",
//            date: "2025-02-10",
//            imageURL: "https://images.unsplash.com/photo-1533158326339-7f3cf2404354?w=600&h=400&fit=crop",
//            category: "전시/미술",
//            template: .grid,
//            averageColorHex: "#D4AF37"
//        ),
//        Ticket(
//            id: "4",
//            title: "연극 <햄릿>",
//            description: "셰익스피어의 고전",
//            date: "2025-02-18",
//            imageURL: "https://images.unsplash.com/photo-1516307365426-bea591f05011?w=600&h=400&fit=crop",
//            category: "연극",
//            template: .floral,
//            averageColorHex: "#5A3E36"
//        ),
//        Ticket(
//            id: "5",
//            title: "재즈 라이브 콘서트",
//            description: "도심 속 재즈의 밤",
//            date: "2025-03-01",
//            imageURL: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&h=400&fit=crop",
//            category: "콘서트",
//            template: .cloud,
//            averageColorHex: "#2C3E50"
//        ),
//        Ticket(
//            id: "6",
//            title: "사진전 <도시의 풍경>",
//            description: "렌즈로 담은 일상의 순간",
//            date: "2025-03-05",
//            imageURL: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600&h=400&fit=crop",
//            category: "전시/사진",
//            template: .grid,
//            averageColorHex: "#6C7A89"
//        ),
//        Ticket(
//            id: "7",
//            title: "클래식 콘서트",
//            description: "베토벤 교향곡",
//            date: "2025-03-12",
//            imageURL: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=600&h=400&fit=crop",
//            category: "클래식",
//            template: .floral,
//            averageColorHex: "#3D3D3D"
//        ),
//        Ticket(
//            id: "8",
//            title: "현대무용 공연",
//            description: "몸으로 표현하는 예술",
//            date: "2025-03-20",
//            imageURL: "https://images.unsplash.com/photo-1515169067865-5387ec356754?w=600&h=400&fit=crop",
//            category: "무용",
//            template: .cloud,
//            averageColorHex: "#9B59B6"
//        ),
//        Ticket(
//            id: "9",
//            title: "독립영화 상영회",
//            description: "감독과의 대화",
//            date: "2025-03-25",
//            imageURL: "https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?w=600&h=400&fit=crop",
//            category: "영화",
//            template: .grid,
//            averageColorHex: "#34495E"
//        ),
//        Ticket(
//            id: "10",
//            title: "아트북 페어",
//            description: "독립 출판의 세계",
//            date: "2025-04-01",
//            imageURL: "https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=600&h=400&fit=crop",
//            category: "전시/출판",
//            template: .floral,
//            averageColorHex: "#C0392B"
//        ),
//        Ticket(
//            id: "11",
//            title: "일러스트 전시",
//            description: "신진 작가들의 작업",
//            date: "2025-04-05",
//            imageURL: "https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=600&h=400&fit=crop",
//            category: "전시/일러스트",
//            template: .cloud,
//            averageColorHex: "#F39C12"
//        ),
//        Ticket(
//            id: "12",
//            title: "인디 밴드 공연",
//            description: "라이브 클럽 공연",
//            date: "2025-04-10",
//            imageURL: "https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2?w=600&h=400&fit=crop",
//            category: "콘서트",
//            template: .grid,
//            averageColorHex: "#1ABC9C"
//        ),
//        Ticket(
//            id: "13",
//            title: "미디어 아트 전시",
//            description: "기술과 예술의 결합",
//            date: "2025-04-15",
//            imageURL: "https://images.unsplash.com/photo-1492724441997-5dc865305da7?w=600&h=400&fit=crop",
//            category: "전시/미디어",
//            template: .floral,
//            averageColorHex: "#16A085"
//        ),
//        Ticket(
//            id: "14",
//            title: "연극 <갈매기>",
//            description: "체홉의 고전",
//            date: "2025-04-20",
//            imageURL: "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=600&h=400&fit=crop",
//            category: "연극",
//            template: .cloud,
//            averageColorHex: "#7F8C8D"
//        ),
//        Ticket(
//            id: "15",
//            title: "발레 <백조의 호수>",
//            description: "클래식 발레의 정수",
//            date: "2025-04-25",
//            imageURL: "https://images.unsplash.com/photo-1509221963536-b7a3d01c07c8?w=600&h=400&fit=crop",
//            category: "발레",
//            template: .grid,
//            averageColorHex: "#2E4053"
//        ),
//        Ticket(
//            id: "16",
//            title: "디자인 전시",
//            description: "타이포그래피의 현재",
//            date: "2025-05-01",
//            imageURL: "https://images.unsplash.com/photo-1500534314209-a26db0f5e58b?w=600&h=400&fit=crop",
//            category: "전시/디자인",
//            template: .floral,
//            averageColorHex: "#95A5A6"
//        ),
//        Ticket(
//            id: "17",
//            title: "문학 북토크",
//            description: "작가와의 만남",
//            date: "2025-05-05",
//            imageURL: "https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=600&h=400&fit=crop",
//            category: "문학",
//            template: .cloud,
//            averageColorHex: "#A04000"
//        ),
//        Ticket(
//            id: "18",
//            title: "포스터 아트 전시",
//            description: "그래픽 디자인 아카이브",
//            date: "2025-05-10",
//            imageURL: "https://images.unsplash.com/photo-1522199710521-72d69614c702?w=600&h=400&fit=crop",
//            category: "전시/그래픽",
//            template: .grid,
//            averageColorHex: "#273746"
//        ),
//        Ticket(
//            id: "19",
//            title: "야외 클래식 공연",
//            description: "공원에서 즐기는 음악",
//            date: "2025-05-15",
//            imageURL: "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=600&h=400&fit=crop",
//            category: "클래식",
//            template: .floral,
//            averageColorHex: "#566573"
//        ),
//        Ticket(
//            id: "20",
//            title: "공예 마켓",
//            description: "핸드메이드 작품 전시",
//            date: "2025-05-20",
//            imageURL: "https://images.unsplash.com/photo-1503602642458-232111445657?w=600&h=400&fit=crop",
//            category: "전시/공예",
//            template: .cloud,
//            averageColorHex: "#AF601A"
//        )
//    ]
}


extension CulturalContentEntity {
    static let mockCulturalContents: [CulturalContentEntity] = [
        CulturalContentEntity(
            id: 2,
            title: "예술의전당 오페라 <라 보엠>",
            imageURL: "https://images.unsplash.com/photo-1580809361436-42a7ec204889?w=600&h=400&fit=crop",
            place: "예술의전당 오페라극장",
            startDate: "2025-01-15",
            endDate: "2025-01-28"
        ),
        CulturalContentEntity(
            id: 3,
            title: "국립현대미술관 서울관 상설전",
            imageURL: "https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=600&h=400&fit=crop",
            place: "국립현대미술관 서울관",
            startDate: "2025-01-01",
            endDate: "2025-12-31"
        ),
        CulturalContentEntity(
            id: 4,
            title: "세종문화회관 뮤지컬 페스티벌",
            imageURL: "https://images.unsplash.com/photo-1503095396549-807759245b35?w=600&h=400&fit=crop",
            place: "세종문화회관 대극장",
            startDate: "2025-02-01",
            endDate: "2025-02-28"
        ),
        CulturalContentEntity(
            id: 5,
            title: "국립극장 전통공연",
            imageURL: "https://images.unsplash.com/photo-1533158326339-7f3cf2404354?w=600&h=400&fit=crop",
            place: "국립극장 해오름극장",
            startDate: "2025-01-20",
            endDate: "2025-01-31"
        ),
        CulturalContentEntity(
            id: 6,
            title: "DDP 디자인전시",
            imageURL: "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600&h=400&fit=crop",
            place: "동대문디자인플라자",
            startDate: "2025-01-08",
            endDate: "2025-04-08"
        ),
        CulturalContentEntity(
            id: 7,
            title: "롯데콘서트홀 신년음악회",
            imageURL: "https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=600&h=400&fit=crop",
            place: "롯데콘서트홀",
            startDate: "2025-01-12",
            endDate: "2025-01-12"
        ),
        CulturalContentEntity(
            id: 8,
            title: "국립민속박물관 특별기획전",
            imageURL: "https://images.unsplash.com/photo-1582555172866-f73bb12a2ab3?w=600&h=400&fit=crop",
            place: "국립민속박물관",
            startDate: "2025-01-05",
            endDate: "2025-03-15"
        ),
        CulturalContentEntity(
            id: 9,
            title: "서울재즈페스티벌",
            imageURL: "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=600&h=400&fit=crop",
            place: "올림픽공원 88잔디마당",
            startDate: "2025-05-01",
            endDate: "2025-05-03"
        ),
        CulturalContentEntity(
            id: 10,
            title: "국립한글박물관 한글특별전",
            imageURL: "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=600&h=400&fit=crop",
            place: "국립한글박물관",
            startDate: "2025-01-08",
            endDate: "2025-06-30"
        ),
        CulturalContentEntity(
            id: 11,
            title: "LG아트센터 발레공연",
            imageURL: "https://images.unsplash.com/photo-1508807526345-15e9b5f4eaff?w=600&h=400&fit=crop",
            place: "LG아트센터",
            startDate: "2025-02-05",
            endDate: "2025-02-14"
        ),
        CulturalContentEntity(
            id: 12,
            title: "북서울미술관 기획전",
            imageURL: "https://images.unsplash.com/photo-1536924940846-227afb31e2a5?w=600&h=400&fit=crop",
            place: "북서울미술관",
            startDate: "2025-01-10",
            endDate: "2025-04-20"
        )
    ]

    // 오늘 날짜 기준 필터링된 데이터
    static var todayEvents: [CulturalContentEntity] {
        return mockCulturalContents.prefix(4).map { $0 }
    }

    // 추천 콘텐츠
    static var recommendedContents: [CulturalContentEntity] {
        return Array(mockCulturalContents.prefix(6))
    }

    // 최근 콘텐츠
    static var latestContents: [String: [CulturalContentEntity]] {
        return [
            "전시/미술": Array(mockCulturalContents.filter { [1, 3, 8, 12].contains($0.id) }),
            "공연": Array(mockCulturalContents.filter { [2, 4, 7, 11].contains($0.id) }),
            "축제": Array(mockCulturalContents.filter { [9].contains($0.id) })
        ]
    }
}
