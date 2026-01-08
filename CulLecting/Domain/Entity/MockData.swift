//
//  MockData.swift
//  CulLecting
//
//  Created for development and testing purposes
//

import Foundation

// MARK: - Mock Data for Development
extension Ticket {
    static let mockTickets: [Ticket] = [
        Ticket(
            id: "1",
            title: "국립중앙박물관 특별전",
            description: "한국 미술의 정수를 담은 특별전시",
            date: "2025-01-15",
            imageURL: "https://images.unsplash.com/photo-1569172122301-bc5008bc09c5?w=400&h=600&fit=crop",
            category: "전시/미술",
            template: .floral,
            averageColorHex: "#8B7355"
        ),
        Ticket(
            id: "2",
            title: "서울시립교향악단 정기연주회",
            description: "베토벤 교향곡 9번 '합창'",
            date: "2025-01-20",
            imageURL: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=600&fit=crop",
            category: "클래식",
            template: .black,
            averageColorHex: "#2C2C2C"
        ),
        Ticket(
            id: "3",
            title: "뮤지컬 <위키드>",
            description: "브로드웨이 대표 뮤지컬",
            date: "2025-02-01",
            imageURL: "https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=400&h=600&fit=crop",
            category: "뮤지컬",
            template: .cloud,
            averageColorHex: "#4A90E2"
        ),
        Ticket(
            id: "4",
            title: "국립국악원 토요명품공연",
            description: "전통국악의 아름다움",
            date: "2025-01-25",
            imageURL: "https://images.unsplash.com/photo-1460881680858-30d872d5b530?w=400&h=600&fit=crop",
            category: "국악",
            template: .white,
            averageColorHex: "#F5F5F5"
        ),
        Ticket(
            id: "5",
            title: "예술의전당 서예전",
            description: "현대 서예의 흐름",
            date: "2025-02-10",
            imageURL: "https://images.unsplash.com/photo-1561214115-f2f134cc4912?w=400&h=600&fit=crop",
            category: "전시/미술",
            template: .grid,
            averageColorHex: "#D4AF37"
        )
    ]
}

extension CulturalContentEntity {
    static let mockCulturalContents: [CulturalContentEntity] = [
        CulturalContentEntity(
            id: 1,
            title: "서울시립미술관 기획전",
            imageURL: "https://images.unsplash.com/photo-1578926288207-a90c5f3c1d86?w=600&h=400&fit=crop",
            place: "서울시립미술관 서소문본관",
            startDate: "2025-01-10",
            endDate: "2025-03-30"
        ),
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
