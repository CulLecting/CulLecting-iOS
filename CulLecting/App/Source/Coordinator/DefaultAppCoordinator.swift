//
//  DefaultAppCoordinator.swift
//  CulLecting
//
//  Created by 김승희 on 4/6/25.
//

import UIKit
import Swinject

public protocol DefaultAppCoordinatorProtocol: Coordinator {
    func showLoginFlow()
    func showOnboardingFlow()
    func showTabbarFlow()
    func setTabbarCoordinator()
    func getChildCoordinator(_ coordinatorType: CoordinatorType) -> Coordinator?
}

// 부모 코디네이터: 앱 실행과 동시에 앱에 대한 제어권을 갖는 첫 번째 코디네이터
class DefaultAppCoordinator: DefaultAppCoordinatorProtocol {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let injector: Resolver
    }
    
    private let dependency: Dependency
    public var childCoordinators = [Coordinator]()
    public var navigationController: UINavigationController
    public var type: CoordinatorType = .app
    public weak var finishDelegate: CoordinatorFinishDelegate?
    
    // 구현 필요
    private var haveToken: Bool = true
    private var hasSeenOnboarding: Bool = true
    
    public init(dependency: Dependency) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
    }
    
    public func start() {
        setNavigationBar()
        haveToken ? ( hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow() ) : showLoginFlow()
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
        guard let onboardingCoordinator = dependency.injector.resolve(OnboardingCoordinator.self, argument: navigationController) else { return }
        onboardingCoordinator.parentCoordinator = self
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    /// 탭바 컨트롤러 플로우
    func showTabbarFlow() {
        print("ShowTabbarFlow 실행됨")
        if getChildCoordinator(.tabbar) == nil {
            setTabbarCoordinator()
        }
        guard let tabbarCoordinator = getChildCoordinator(.tabbar) as? TabbarCoordinator else { return }
        tabbarCoordinator.parentCoordinator = self
        tabbarCoordinator.start()
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
    func getChildCoordinator(_ coordinatorType: CoordinatorType) -> (any Coordinator)? {
        switch coordinatorType {
        case .tabbar:
            return childCoordinators.first { $0.type == .tabbar }
        default:
            return nil
        }
    }
    
    /// UINavigationContoller의 NavigationBar 설정
    func setNavigationBar() {
        navigationController.setNavigationBarHidden(false, animated: true)
    }
    
}

/// 자식 코디네이터가 종료되었을 때 실행할 메서드
extension DefaultAppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        print("coordinatorDidFinish() 호출됨")
        self.childCoordinators = self.childCoordinators.filter { $0.type != childCoordinator.type }
        print("OnboardingFinish - TabbarFlowStart")
        showTabbarFlow()
    }
}

/// 이벤트 처리
extension DefaultAppCoordinator {
    public func didLoggedIn() {
        hasSeenOnboarding ? showTabbarFlow() : showOnboardingFlow()
    }
    
    public func didLoggedOut() {
        childCoordinators.removeAll()
        showLoginFlow()
    }
}
