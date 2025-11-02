# CulLecting (컬렉팅)

> 공공데이터 기반 문화행사 정보를 티켓 형식으로 아카이빙하고, 사용자 취향에 맞는 문화행사를 추천하는 iOS 앱

---

## 📱 프로젝트 소개

**CulLecting**은 관람한 문화행사를 티켓 형식으로 수집하고, 취향 분석을 통해 개인 맞춤형 문화행사를 추천하는 iOS 어플리케이션입니다.

### 주요 기능
- 📸 **티켓 아카이빙**: 관람한 문화행사를 티켓 형식으로 저장
- 🎭 **취향 카드**: 티켓 수집 시 취향 분석을 통한 '취향 카드' 생성
- 🔍 **맞춤형 추천**: 사용자 선호도 기반 문화행사 추천
- 🔎 **필터 검색**: 지역, 카테고리, 연령, 비용 기반 검색
- 👤 **사용자 관리**: 이메일 인증 기반 회원가입 및 로그인

| 홈, 검색 |  |  |
|:--:|:--:|:--:|
| <img width="670" height="1383" alt="image" src="https://github.com/user-attachments/assets/156ccfca-e9ca-4193-bc06-7aabc5e5f4f1" /> | <img width="606" height="1312" alt="image" src="https://github.com/user-attachments/assets/795baaa6-0e04-4cd6-a23a-1ede2889224f" /> | <img width="606" height="1312" alt="image" src="https://github.com/user-attachments/assets/4aec846f-597f-47b0-9ac0-5107490ff448" /> |

| 아카이빙 |  |  |
|:--:|:--:|:--:|
| <img width="670" height="1383" alt="image" src="https://github.com/user-attachments/assets/2c81656e-a792-41a9-944e-94681e19fe29" /> | <img width="606" height="1312" alt="image" src="https://github.com/user-attachments/assets/33c13147-3934-45a6-8da7-2188a962e340" /> | <img width="606" height="1312" alt="image" src="https://github.com/user-attachments/assets/f6428208-e04f-45b7-a806-4d0073b0f9fb" /> |

| 큐레이팅 |  |  |
|:--:|:--:|:--:|
| <img width="589" height="1215" alt="image" src="https://github.com/user-attachments/assets/f3a33285-d846-42f0-96a5-964fa920b458" /> | <img width="533" height="1153" alt="image" src="https://github.com/user-attachments/assets/fb33dfcf-1495-4f41-ace6-1ad4050eccbb" /> | <img width="597" height="1217" alt="image" src="https://github.com/user-attachments/assets/b101a766-ec17-4a73-9dd0-c2a2099934f4" /> |





---

## 🏆 성과

- **서울 열린데이터광장 공모전 출품**
- **App Store 정식 배포**

---

## 🛠 기술 스택

### Architecture & Design Pattern
- **Clean Architecture** (Data-Domain-Presentation 3계층)
- **MVVM-C** (Model-View-ViewModel-Coordinator)
- **Coordinator Pattern** (화면 전환 로직 중앙 관리)
- **Repository Pattern** (데이터 소스 추상화)

### Framework & Library
- **Language**: Swift
- **UI**: UIKit, FlexLayout, PinLayout, SnapKit
- **Reactive**: RxSwift, RxCocoa
- **DI**: Swinject
- **Network**: Alamofire
- **Database**: CoreData
- **Security**: Keychain Services
- **Image**: Kingfisher
- **Dependency Manager**: Swift Package Manager

---

## 🏗 아키텍처

### Clean Architecture 3계층 구조

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (ViewController, ViewModel, View)      │
└──────────────┬──────────────────────────┘
               │ depends on
┌──────────────▼──────────────────────────┐
│          Domain Layer                   │
│  (Entity, UseCase, Repository Protocol) │
└──────────────┬──────────────────────────┘
               │ implements
┌──────────────▼──────────────────────────┐
│           Data Layer                    │
│  (Repository, API Client, DTO)          │
└─────────────────────────────────────────┘
```

### 의존성 역전 원칙
- Domain Layer의 Repository Protocol을 Data Layer가 구현
- ViewModel → UseCase → Repository Protocol 순으로 의존
- 도메인 로직의 독립성 확보

---

## 🎯 기술적 도전과 해결

### 1. Clean Architecture 적용

**문제 인식**

백엔드 개발자와 협업하면서 다양한 API 엔드포인트가 추가되고, 이에 따라 Network 관련 파일, API 정의, DTO 등이 급격히 증가했습니다. 단순히 ViewController만 비대해지는 것이 아니라, ViewModel에도 네트워크 로직, 데이터 변환 로직, 비즈니스 로직이 혼재되어 역할이 불명확해지고 있었습니다.

또한 새로운 화면을 추가할 때마다 "이 로직은 ViewModel에 둬야 하나, 별도 Manager에 둬야 하나?"와 같은 고민이 반복되었고, 팀원 간 코드 작성 방식이 통일되지 않아 일관성이 떨어지는 문제가 발생했습니다. 프로젝트 초기에 명확한 아키텍처 규칙을 정립하지 않으면, 프로젝트가 커질수록 유지보수가 어려워질 것이라 판단했습니다.

**해결 방안**

Clean Architecture를 도입하여 Data-Domain-Presentation 3계층으로 명확히 분리했습니다.

- **Data Layer**: API 통신, DTO 정의, Repository 구현체를 담당. 네트워크 관련 로직은 모두 이 계층에서 처리
- **Domain Layer**: 비즈니스 로직을 UseCase로 추상화하고, Repository Protocol로 데이터 소스를 추상화. 외부 의존성 없이 순수한 도메인 로직만 포함
- **Presentation Layer**: ViewModel은 UseCase만 의존하고, UI 상태 관리에만 집중. View는 ViewModel을 통해서만 데이터에 접근

이를 통해 "어디에 어떤 로직을 둬야 하는가"에 대한 명확한 기준이 생겼고, 새로운 기능 추가 시 일관된 구조를 유지할 수 있었습니다. 또한 UseCase 단위로 비즈니스 로직을 분리하여 테스트 가능한 코드를 작성할 수 있었습니다.

**결과**

- ViewModel의 역할을 UI 상태 관리로 제한하여 비대화 방지
- 새로운 API 추가 시 Data Layer만 수정하면 되어 변경 영향 범위 최소화
- 팀원 간 코드 작성 방식 통일로 코드 리뷰 및 협업 효율성 향상

---

### 2. 토큰 자동 갱신 메커니즘

**문제 인식**

AccessToken은 보안을 위해 짧은 만료 시간(예: 1시간)을 가지는데, 만료될 때마다 사용자가 다시 로그인해야 한다면 사용자 경험이 크게 저하됩니다. 또한 앱 사용 중 갑자기 로그인 화면으로 튀는 것은 사용자에게 혼란을 줄 수 있습니다.

**해결 방안**

RefreshToken을 활용한 자동 토큰 갱신 메커니즘을 구현했습니다.

1. **401 에러 감지**: 네트워크 요청 시 401 Unauthorized 에러가 발생하면 토큰 만료로 판단
2. **자동 갱신**: RefreshToken을 사용해 새로운 AccessToken을 발급받는 API 호출
3. **요청 재시도**: 새 토큰을 Keychain에 저장 후, 실패했던 원래 요청을 자동으로 재시도
4. **RxSwift catch 연산자**: 에러 스트림을 캐치하여 토큰 갱신 로직을 삽입하고, flatMap으로 원래 요청 재실행

```swift
func request<T: Decodable>(endpoint: URLRequestConvertible) -> Single<T> {
    return networkManager.request(endpoint)
        .catch { error in
            if error.isTokenExpired {
                return self.refreshToken()
                    .flatMap { _ in self.networkManager.request(endpoint) }
            }
            return Single.error(error)
        }
}
```

**결과**

- 사용자는 토큰 만료를 인지하지 못하고 끊김 없이 앱 사용 가능
- 자동 로그인 유지로 사용자 경험 크게 개선
- RefreshToken 만료 시에만 로그인 화면으로 이동하도록 처리

---

### 3. Coordinator 패턴 도입

**문제 인식**

초기에는 ViewController에서 다음 화면을 직접 push하는 방식으로 개발했습니다. 그러나 프로젝트가 커지면서 화면 전환 로직이 여러 ViewController에 분산되어 전체 플로우를 파악하기 어려웠고, ViewController 간 결합도가 높아 유지보수가 어려워졌습니다.

특히 "로그인 → 온보딩 → 메인 화면" 같은 복잡한 플로우에서 각 화면이 다음 화면을 알아야 하는 구조는 변경에 취약했습니다.

**해결 방안**

Coordinator 패턴을 도입하여 모든 화면 전환 로직을 중앙에서 관리하도록 개선했습니다.

- **FirstCoordinator**: 앱 시작 시 토큰 및 온보딩 상태를 검증하고, LoginCoordinator/OnboardingCoordinator/TabbarCoordinator로 분기
- **기능별 Coordinator**: LoginCoordinator는 로그인/회원가입/비밀번호 재설정 플로우를 담당, TabbarCoordinator는 탭 네비게이션 관리
- **ViewController 독립성**: ViewController는 Coordinator에게 이벤트만 전달하고(예: `coordinator.didLoginSuccess()`), 다음 화면에 대해 알지 못함

**결과**

- 전체 앱 플로우를 Coordinator 코드만 보고 파악 가능
- ViewController 간 결합도 제거로 재사용성 향상
- 화면 전환 로직 변경 시 Coordinator만 수정하면 되어 유지보수 용이

---

### 4. 커스텀 CarouselView 구현

**문제 인식**

아카이빙 화면에서 티켓을 카드 형태의 Carousel로 보여주는 UI가 필요했습니다. 디자이너는 다음과 같은 요구사항을 제시했습니다:

1. 첫 번째 카드와 마지막 카드도 화면 중앙에 정렬
2. 스크롤 시 중앙 카드는 크게, 양옆 카드는 작게 보이는 거리 기반 transform 효과
3. 스크롤 종료 시 가장 가까운 카드로 부드럽게 스냅

UICollectionView로 구현을 고려했으나, 다음과 같은 문제가 있었습니다:
- 셀 재사용으로 인해 화면 밖 셀 접근이 제한적이어서 실시간 transform 효과 구현이 복잡함
- 첫/마지막 카드 중앙 정렬을 위한 커스텀 레이아웃 구현이 번거로움

**해결 방안**

UIScrollView를 직접 활용하여 커스텀 CarouselView를 구현했습니다.

**1. 중앙 정렬 레이아웃**
```swift
let cardHeight = bounds.height * 0.85
let cardWidth = cardHeight * 0.62
let spacer = (bounds.width - cardWidth) / 2  // 양쪽 여백 계산
```
양쪽에 spacer를 추가하여 첫/마지막 카드도 화면 중앙에 위치하도록 구현

**2. 실시간 거리 기반 Transform 효과**
```swift
private func updateTransforms() {
    let centerX = scrollView.contentOffset.x + bounds.width / 2
    
    for cardView in cardViews {
        let distance = abs(centerX - cardView.center.x)
        let maxDistance = bounds.width / 2 + cardView.bounds.width / 2
        let scale = max(0.9, 1 - distance / maxDistance * 0.1)
        let alpha = max(0.5, 1 - distance / maxDistance)
        
        cardView.transform = CGAffineTransform(scaleX: scale, y: scale)
        cardView.alpha = alpha
    }
}
```
`scrollViewDidScroll` 델리게이트에서 모든 카드의 중앙 거리를 계산하여 scale과 alpha를 실시간 업데이트. UIScrollView는 모든 카드에 직접 접근 가능하여 UICollectionView보다 구현이 단순함

**3. 커스텀 스냅 로직**
```swift
private func snapToNearestCard() {
    let totalWidth = cardWidth + cardSpacing
    let centerOffset = scrollView.contentOffset.x + bounds.width / 2
    let adjustedOffset = centerOffset - spacer
    let index = Int(round((adjustedOffset - cardWidth / 2) / totalWidth))
    scrollToIndex(index: index, animated: true)
}
```
스크롤 종료 시 중앙에 가장 가까운 카드 인덱스를 계산하여 부드럽게 스냅

**UIScrollView 선택 근거**
- **실시간 제어**: 모든 카드에 대한 직접 접근으로 거리 기반 transform 효과 구현 용이
- **정확한 레이아웃**: 첫/마지막 카드 중앙 정렬을 spacer 계산만으로 간단히 구현
- **단순한 구조**: 셀 등록, DataSource/Delegate 불필요, 티켓 수가 제한적이어서 메모리 효율성 문제 없음
- **커스텀 스냅**: 스냅 위치와 동작을 정확히 제어 가능

**결과**

- 디자이너가 요청한 중앙 정렬 및 거리 기반 transform 효과 완벽 구현
- 부드러운 스냅 애니메이션으로 사용자 경험 향상
- UICollectionView 대비 단순한 구조로 유지보수 용이
- 티켓 개수가 적어 UIScrollView로 충분히 성능 확보

**한계 및 개선 방향**

만약 티켓 개수가 수십 개 이상으로 증가한다면, UICollectionView로 리팩토링하여 셀 재사용을 통한 메모리 최적화가 필요할 수 있습니다.

---

## 👥 팀 구성

- **iOS Developer**: 1명 (단독 개발)
- **Designer**: 1명
- **BE**: 1명
- **PM**: 1명

---

## 📅 개발 기간

**2025.03 - 2025.05** (약 2개월)
