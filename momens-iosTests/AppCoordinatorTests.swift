//
//  AppCoordinatorTests.swift
//  momens-iosTests
//

@testable import momens_ios
import XCTest

final class AppCoordinatorTests: XCTestCase {
    func testMoveToSignInUpdatesAppState() {
        let coordinator = AppCoordinator()

        coordinator.moveToSignIn()

        XCTAssertEqual(coordinator.state, .signIn)
    }

    func testMoveToOnboardingUpdatesAppState() {
        let coordinator = AppCoordinator()

        coordinator.moveToOnboarding()

        XCTAssertEqual(coordinator.state, .onboarding)
    }

    func testMoveToMainUpdatesAppState() {
        let coordinator = AppCoordinator()

        coordinator.moveToMain()

        XCTAssertEqual(coordinator.state, .main)
    }
}
