//
//  FirstAppCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit

import RxSwift
import Swinject

public protocol FirstCoordinatorProtocol: CoordinatorProtocol {
    func showLoginFlow()
    func showOnboardingFlow()
    func showTabbarFlow()
    func setTabbarCoordinator()
    func getChildCoordinator(_ coordinatorType: CoordinatorType) -> CoordinatorProtocol?
    func replaceRootViewController(with viewController: UIViewController)
    func didLoggedIn()
    func didLoggedOut()
}

// 부모 코디네이터: 앱 실행과 동시에 앱에 대한 제어권을 갖는 첫 번째 코디네이터
class FirstCoordinator: FirstCoordinatorProtocol {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let injector: Resolver
    }
    
    private let dependency: Dependency
    public var childCoordinators = [CoordinatorProtocol]()
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .app
    public weak var finishDelegate: CoordinatorFinishDelegate?
    private let disposeBag = DisposeBag()
    
    //MARK: 토큰 & 온보딩 처리
    private var haveToken: Bool {
        return TokenStorage.shared.accessToken != nil
    }

    private var hasSeenOnboarding: Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    //MARK: init
    public init(dependency: Dependency) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
    }
    
    func start() {
        navigationController.isNavigationBarHidden = true
        
        validateAccessToken { [weak self] isValid in
            guard let self else { return }
            
            if isValid {
                hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
            } else {
                TokenStorage.shared.clearAll()
                print("토큰 삭제됨")
                showLoginFlow()
            }
        }
    }
    
    /// VC 전환 메서드
    func replaceRootViewController(with viewController: UIViewController) {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    func showLoginFlow() {
        print("showLoginFlow 실행됨")
        // DI Container를 통해 LoginCoordinator 생성
        guard let loginCoordinator = dependency.injector.resolve(LoginCoordinator.self, argument: navigationController) else { return }
        loginCoordinator.parentCoordinator = self
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    func showOnboardingFlow() {
        print("showOnboardingFlow 실행됨")
        navigationController.isNavigationBarHidden = false
        
        guard let onboardingCoordinator = dependency.injector.resolve(OnboardingCoordinator.self, argument: navigationController) else { return }
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.finishDelegate = self
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    /// 탭바 컨트롤러 플로우
    func showTabbarFlow() {
        print("ShowTabbarFlow 실행됨")
        navigationController.setViewControllers([], animated: false)
        
        if getChildCoordinator(.tabbar) == nil {
            setTabbarCoordinator()
        }
        guard let tabbarCoordinator = getChildCoordinator(.tabbar) as? TabbarCoordinator else { return }
        tabbarCoordinator.parentCoordinator = self
        tabbarCoordinator.start()
        
        replaceRootViewController(with: tabbarCoordinator.navigationController)
    }
    
    /// 탭바 컨트롤러 세팅, 자식 코디네이터로 등록
    func setTabbarCoordinator() {
        guard let tabbarCoordinator = dependency.injector.resolve(TabbarCoordinator.self, argument: navigationController) else {
            fatalError("TabbarCoordinator Resolve 실패")
        }
        tabbarCoordinator.parentCoordinator = self
        childCoordinators.append(tabbarCoordinator)
    }
    
    /// 앱 코디네이터의 자식 코디네이터 get
    func getChildCoordinator(_ coordinatorType: CoordinatorType) -> (any CoordinatorProtocol)? {
        switch coordinatorType {
        case .tabbar:
            return childCoordinators.first { $0.type == .tabbar }
        default:
            return nil
        }
    }
    
    /// 토큰 유효성 검증 메서드
    private func validateAccessToken(completion: @escaping (Bool) -> Void) {
        let repo = AuthRepository()
        repo.fetchUserInfo()
            .subscribe(onSuccess: { _ in completion(true) },
                       onFailure: { _ in completion(false) })
            .disposed(by: disposeBag)
    }
}

/// 자식 코디네이터가 종료되었을 때 실행할 메서드
extension FirstCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: CoordinatorProtocol) {
        print("coordinatorDidFinish() 호출됨")
        self.childCoordinators = self.childCoordinators.filter { $0.type != childCoordinator.type }
        print("OnboardingFinish - TabbarFlowStart")
        showTabbarFlow()
    }
}

/// 이벤트 처리
extension FirstCoordinator {
    public func didLoggedIn() {
        print("didloggedin called")
        hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
    }
    
    public func didLoggedOut() {
        childCoordinators.removeAll()
        showLoginFlow()
    }
}
