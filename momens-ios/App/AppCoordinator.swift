import Observation

@Observable
final class AppCoordinator {
    private(set) var state: AppState = .splash

    func moveToSplash() {
        state = .splash
    }

    func moveToSignIn() {
        state = .signIn
    }

    func moveToOnboarding() {
        state = .onboarding
    }

    func moveToMain() {
        state = .main
    }
}
