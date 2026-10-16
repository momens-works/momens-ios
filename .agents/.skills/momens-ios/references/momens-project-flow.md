# Momens Project Flow

This document defines the SwiftUI conventions followed by the Momens iOS project.

It is more specific than the general SwiftUI flow and exists to align with the Momens folder structure, MVVM flow, and code style. It mirrors `momens-android` so the two apps stay easy to compare.

Examples use feature names that already exist in the project, such as `Signal`, `Project`, `Brief`, `SignIn`, `Splash`, and `Main`.

---

## 1. Create ViewModels Through DIContainer

ViewModels in the Momens project are `@Observable` classes that receive dependencies through their initializer. They are assembled in `App/DI/`, which plays the role of Hilt modules on Android.

The project uses main-actor default isolation, so ViewModels run on the main actor without an explicit `@MainActor`. If that build setting is ever turned off, add `@MainActor` to every ViewModel.

### ViewModel Example

```swift
import Combine
import Observation

@Observable
final class SignalViewModel {
    private(set) var uiState: UiState<SignalUiState> = .loading
    let sideEffect = PassthroughSubject<SignalSideEffect, Never>()

    private let repository: SignalRepository

    init(repository: SignalRepository) {
        self.repository = repository
    }
}
```

### DIContainer Example

`DIContainer.swift` holds the shared dependencies (network client, storage, repositories) as `lazy var`s. Swift extensions cannot add stored properties, so each feature adds only its ViewModel factory in `DIContainer+Feature.swift`.

```swift
// App/DI/DIContainer.swift
final class DIContainer {
    // Core
    lazy var apiClient = APIClient(baseURL: AppConfig.baseURL)

    // Data
    lazy var signalRepository: SignalRepository = SignalRepositoryImpl(
        remoteDataSource: SignalRemoteDataSourceImpl(apiClient: apiClient)
    )
}

// App/DI/DIContainer+Signal.swift
extension DIContainer {
    func makeSignalViewModel() -> SignalViewModel {
        SignalViewModel(repository: signalRepository)
    }
}
```

The app entry point creates one `DIContainer` and passes it down to the navigation stacks (section 6). Do not use a global singleton.

### View Example

The `XxxView` layer owns the ViewModel with `@State`. Navigation is not done here. The View receives navigation closures from the `XxxNavigationStack` that creates it.

```swift
struct SignalView: View {
    @State private var viewModel: SignalViewModel
    private let onNavigateToProject: (Int) -> Void

    init(
        viewModel: SignalViewModel,
        onNavigateToProject: @escaping (Int) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onNavigateToProject = onNavigateToProject
    }

    var body: some View {
        SignalScreen(
            uiState: viewModel.uiState,
            onSignalTap: viewModel.onSignalTap
        )
        .onReceive(viewModel.sideEffect) { sideEffect in
            switch sideEffect {
            case .navigateToProject(let projectId):
                onNavigateToProject(projectId)
            case .showSnackbar:
                break
            }
        }
        .task { await viewModel.loadSignals() }
    }
}
```

Do not reference the ViewModel directly from `Screen` or `Component` layers. Do not access `DIContainer` from `Screen` or `Component`. Only the app entry point and the `XxxNavigationStack` files use it.

---

## 2. Separate View / Screen / Component Responsibilities

Screens should be split into `View`, `Screen`, and `Component` layers when possible.

| Layer | Android equivalent | Responsibility |
| --- | --- | --- |
| `XxxView` | `XxxRoute` | Own ViewModel, read UiState, handle SideEffects, call navigation closures |
| `XxxScreen` | `XxxScreen` / `XxxContent` | Receive state and event closures, render UI only |
| `Component` | `component` | Reusable UI unit, no direct ViewModel or navigation reference |

`XxxRoute` is used for navigation enums on iOS, which is why the Android `XxxRoute` role is called `XxxView` here.

### View Example

See the `SignalView` example in section 1.

### Screen Example

```swift
struct SignalScreen: View {
    let uiState: SignalUiState
    let onSignalTap: (Int) -> Void

    var body: some View {
        SignalContent(
            signals: uiState.signals,
            onSignalTap: onSignalTap
        )
    }
}
```

### Component Example

```swift
struct SignalCard: View {
    let title: String
    let summary: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading) {
                Text(title)
                Text(summary)
            }
        }
        .buttonStyle(.plain)
    }
}
```

---

## 3. Common UiState Pattern

Screens that render API results should clearly separate `loading`, `success`, and `failure` states.

`Core/Common/State/UiState.swift`:

```swift
enum UiState<T> {
    case empty
    case loading
    case success(T)
    case failure

    var data: T? {
        if case .success(let data) = self { return data }
        return nil
    }
}

extension UiState: Equatable where T: Equatable {}
```

In the ViewModel, screen-specific state can be wrapped as `UiState<XxxUiState>`.

```swift
private(set) var uiState: UiState<SignalUiState> = .loading
```

In the View, separate UI by state.

```swift
var body: some View {
    Group {
        switch viewModel.uiState {
        case .loading:
            LoadingView()

        case .failure:
            ErrorContent(
                onRetryTap: { Task { await viewModel.loadSignals() } }
            )

        case .success(let state):
            SignalScreen(
                uiState: state,
                onSignalTap: viewModel.onSignalTap
            )

        case .empty:
            EmptyView()
        }
    }
    .task { await viewModel.loadSignals() }
}
```

Repositories expose `async throws` functions. Map the result inside the ViewModel with `do` / `catch`.

```swift
func loadSignals() async {
    do {
        let signals = try await repository.getSignals()
        uiState = .success(SignalUiState(signals: signals.map { $0.toUiModel() }))
    } catch {
        uiState = .failure
        sideEffect.send(.showSnackbar(message: "시그널을 불러오지 못했습니다."))
    }
}
```

---

## 4. SideEffect Handling Rules

One-time events such as navigation, Toast, Snackbar, and alert display should not be stored in `UiState`. Separate them into `SideEffect`.

```swift
enum SignalSideEffect {
    case navigateToProject(projectId: Int)
    case showSnackbar(message: String)
}
```

Expose SideEffects from the ViewModel with `PassthroughSubject`. It behaves like Android `MutableSharedFlow` with no replay: values are delivered only to current subscribers.

```swift
let sideEffect = PassthroughSubject<SignalSideEffect, Never>()

func onSignalTap(_ id: Int) {
    sideEffect.send(.navigateToProject(projectId: id))
}
```

Consume SideEffects in the `XxxView` layer with `.onReceive`.

```swift
.onReceive(viewModel.sideEffect) { sideEffect in
    switch sideEffect {
    case .navigateToProject(let projectId):
        onNavigateToProject(projectId)

    case .showSnackbar(let message):
        snackbar.show(message)
    }
}
```

Do not use `AsyncStream` for SideEffects consumed with `.task { for await ... }`. When the View disappears (for example, after pushing another screen), `.task` is cancelled, which finishes the stream, so the screen stops receiving SideEffects when the user comes back.

---

## 5. Use The Momens Design System

Colors, typography, and shapes should come from `Core/DesignSystem` first.

### Recommended

After project-specific design tokens are added, prefer the agreed Momens APIs. The names below are examples. Follow the actual token names in `Core/DesignSystem/Theme`.

```swift
Text(title)
    .foregroundStyle(MomensColor.gray1000)
    .momensFont(.title1SB18)
```

### Avoid

```swift
Text(title)
    .foregroundStyle(.black)
    .font(.system(size: 18, weight: .semibold))
```

Token names should match `momens-android` (`MomensTheme.colors.gray1000`, `MomensTheme.typography.title1SB18`) so designers and both platforms share one vocabulary.

If a new color or typography style is needed, consider adding it to the design system instead of hardcoding it inside a screen.

---

## 6. Typed Navigation Rules

Navigation is split by owner. Do not use string identifiers, one global `Route` enum, or `NavigationLink(destination:)` inside screens.

| Level | Type | Location | Role |
| --- | --- | --- | --- |
| App | `AppState` + `AppCoordinator` | `App/` | Chooses the root screen: `splash`, `signIn`, `onboarding`, `main` |
| Main tabs | `MainTab` + `MainTabCoordinator` | `Presentation/Main/` | Selected tab and one typed path per tab |
| Feature | `XxxRoute` + `XxxNavigationStack` | `Presentation/{Feature}/Navigation/` | Route cases of one tab and the View each case builds |

### App level

`SignIn`, `Onboarding` and `Main` are not pushed on a stack. They replace each other at the root, so they are cases of `AppState`.

```swift
enum AppState {
    case splash
    case signIn
    case onboarding
    case main
}

@Observable
final class AppCoordinator {
    private(set) var state: AppState = .splash

    func moveToSignIn() { state = .signIn }
    func moveToOnboarding() { state = .onboarding }
    func moveToMain() { state = .main }
}
```

The `@main` App switches on `appCoordinator.state` and shows the matching root View.

### Main tabs

`MainTabCoordinator` keeps the selected tab and a separate typed path for each tab, so every tab keeps its own stack when the user switches tabs.

```swift
enum MainTab: Hashable {
    case signal
    case project
    case brief
}

@Observable
final class MainTabCoordinator {
    var selectedTab: MainTab = .signal
    var signalPath: [SignalRoute] = []
    var projectPath: [ProjectRoute] = []
    var briefPath: [BriefRoute] = []
}
```

### Feature level

Each tab owns its `Route` enum and a `NavigationStack` wrapper.

`Presentation/Project/Navigation/ProjectRoute.swift`:

```swift
enum ProjectRoute: Hashable {
    case task(projectId: Int)
    case taskDetail(taskId: String)
    case taskEdit(taskId: String)
}
```

`Presentation/Signal/Navigation/SignalNavigationStack.swift`:

```swift
struct SignalNavigationStack: View {
    @Environment(MainTabCoordinator.self) private var coordinator
    let container: DIContainer

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.signalPath) {
            SignalView(
                viewModel: container.makeSignalViewModel(),
                onNavigateToProject: { projectId in
                    coordinator.selectedTab = .project
                    coordinator.projectPath = [.task(projectId: projectId)]
                }
            )
            .navigationDestination(for: SignalRoute.self) { route in
                // Build the View for every SignalRoute case here.
            }
        }
    }
}
```

Rules:

- Only `XxxNavigationStack` files read the coordinator and create ViewModels through `DIContainer`.
- `XxxView` receives navigation closures. It never touches a coordinator.
- `Screen` and `Component` know nothing about navigation.
- Every new `XxxRoute` case must be handled in that feature's `navigationDestination`.
- `Core/Navigation` is for navigation helpers shared by several features. Feature-specific routes do not go there.

### Avoid

```swift
NavigationLink(destination: ProjectView(id: id)) { ... }  // inside a component
```

### Recommended

```swift
onNavigateToProject(projectId)  // inside XxxView, usually from a SideEffect
```

---

## 7. Folder Structure Rules

New files should follow the existing feature structure. Folder names use PascalCase. Paths are relative to the repository root. The source root is `momens-ios/`.

```text
momens-ios/Presentation/{Feature}/XxxView.swift
momens-ios/Presentation/{Feature}/XxxScreen.swift
momens-ios/Presentation/{Feature}/XxxViewModel.swift
momens-ios/Presentation/{Feature}/State/XxxContract.swift      // XxxUiState + XxxSideEffect
momens-ios/Presentation/{Feature}/Component/
momens-ios/Presentation/{Feature}/Model/                        // XxxUiModel, toUiModel()
momens-ios/Presentation/{Feature}/Navigation/                   // XxxRoute, XxxNavigationStack
momens-ios/Core/Common/{Extension,Logger,Permission,State,Util}/
momens-ios/Core/DesignSystem/{Component,Effect,Theme}/
momens-ios/Core/Network/                                        // EndPoint, interceptor, base DTO
momens-ios/Core/Local/                                          // Keychain, UserDefaults
momens-ios/Core/Navigation/                                     // shared navigation helpers
momens-ios/Core/FCM/
momens-ios/Data/{Feature}/Remote/API/                           // XxxAPI enums (EndPoint)
momens-ios/Data/{Feature}/Remote/DTO/Request/
momens-ios/Data/{Feature}/Remote/DTO/Response/
momens-ios/Data/{Feature}/Remote/DataSource/
momens-ios/Data/{Feature}/Remote/DataSourceImpl/
momens-ios/Data/{Feature}/Model/
momens-ios/Data/{Feature}/Repository/
momens-ios/Data/{Feature}/RepositoryImpl/
momens-ios/App/DI/                                              // DIContainer, DIContainer+Feature
momens-ios/Resources/                                           // Assets.xcassets
```

`Project` groups `Task`, `TaskDetail`, and `TaskEdit` as sub-features (`Presentation/Project/Task/...`, `Data/Project/Task/...`). Shared project navigation lives in `Presentation/Project/Navigation/`.

Unlike Android, dependency wiring does not live in a per-feature `di/` folder. It goes in `App/DI/` (`DIContainer.swift` plus one `DIContainer+Feature.swift` per feature). Route enums stay with their feature in `Presentation/{Feature}/Navigation/`.

Put the ViewModel at the feature folder root. Do not create a separate `ViewModel/` folder.

Feature-specific components should be placed in the feature `Component/` folder.

Components reused across multiple screens should be considered for `Core/DesignSystem/Component/`.

Empty folders hold a `.gitkeep`. It is excluded from the app target in `project.pbxproj`, so a new `.gitkeep` must be added to the `membershipExceptions` list there, or the build fails with "Multiple commands produce '.gitkeep'". Delete the `.gitkeep` and its exception entry once a real file is added to the folder.

The project uses Xcode synchronized folders. Creating a file in the right folder on disk is enough; do not edit `momens-ios.xcodeproj/project.pbxproj` by hand except for the `.gitkeep` exception above.

Local storage folders (`Data/{Feature}/Local/DataSource`, `Local/DataSourceImpl`) are added only when a feature needs them.

---

## 8. MockData / Preview Rules Before API Integration

Even before APIs are connected, do not hardcode temporary data directly inside Views.

Define the screen contract first with `XxxUiState` and required `XxxUiModel` types. Then create fake state for previews or temporary UI checks.

### Rules

- `Screen` receives `XxxUiState`, not fake data directly.
- Fake/mock data lives in a `static let` on `XxxUiState` (in an extension) or near the preview as private values.
- Fake data should be easy to replace with ViewModel repository result mapping.
- Previews must not use ViewModel, Repository, DIContainer, or Network.
- Keep View / Screen / Component separation even before API integration.
- MockData is only for UI implementation and preview checks. It must not replace business logic.

### Example

```swift
struct SignalUiState: Equatable {
    var userName: String = ""
    var signals: [SignalUiModel] = []
}

extension SignalUiState {
    static let fake = SignalUiState(
        userName: "Hyemin",
        signals: [
            SignalUiModel(
                id: 1,
                title: "API response shape requires a decision",
                summary: "This affects the project detail and brief screens."
            ),
            SignalUiModel(
                id: 2,
                title: "Deployment risk to review today",
                summary: "Token refresh failure cases need to be checked."
            ),
        ]
    )
}
```

For screens where state matters, define state-specific fake values.

```swift
extension SignalUiState {
    static let fakeNormal = SignalUiState(...)
    static let fakeEmpty = SignalUiState(...)
    static let fakeLongText = SignalUiState(...)
}
```

Wrap fake values in `#if DEBUG` if they should not ship in release builds.

---

## 9. Strengthen Previews

Important screens and reusable components should have previews.

Preview rules:

- Use the `#Preview` macro.
- Give each preview a name that makes the target and state clear.
- Do not use real ViewModel, Repository, DIContainer, or Network.
- Use fake UiState or sample models.
- `XxxView` needs a ViewModel, so preview its `Screen` instead of the `View`.

### Basic Preview Example

```swift
#Preview("Signal - Default") {
    SignalScreen(
        uiState: .fake,
        onSignalTap: { _ in }
    )
}
```

### State Preview Example

```swift
#Preview("Signal - Empty") {
    SignalScreen(
        uiState: .fakeEmpty,
        onSignalTap: { _ in }
    )
}
```

Preview these states when possible:

- Default state
- Empty state
- Long text state
- Many-list-items state
- Selected/unselected state
- Disabled state
- Loading state
- Error state

---

## 10. Use Value-Type UI Models

Swift arrays and structs are value types, so the Android `ImmutableList` rule becomes:

- UI models are `struct`s, not classes.
- UI model properties are `let` unless the model is a mutable form state.
- UI models conform to `Equatable`, and to `Identifiable` when shown in a list.
- `XxxUiState` conforms to `Equatable` so SwiftUI can skip unnecessary updates.

```swift
struct SignalUiModel: Identifiable, Equatable {
    let id: Int
    let title: String
    let summary: String
}
```

Map DTOs to UI models before updating state.

```swift
uiState = .success(
    SignalUiState(signals: response.signals.map { $0.toUiModel() })
)
```

To update a part of the success state, use a helper on `UiState` instead of rebuilding everything by hand.

```swift
extension UiState {
    mutating func updateSuccess(_ transform: (inout T) -> Void) {
        guard case .success(var data) = self else { return }
        transform(&data)
        self = .success(data)
    }
}
```

---

## 11. Prefer Design System Components

Before styling SwiftUI controls directly, check existing project components for UI such as Button, TextField, Header, Tag, Loading, Snackbar, and BottomSheet.

For bottom sheets, use the shared Momens bottom sheet component (built on `.sheet` + `.presentationDetents`) instead of configuring `.sheet` per screen.

When creating new components, prioritize project colors, typography, and spacing tokens.

---

## 12. Loading / Failure UI Rules

Screens that render API results should clearly handle Loading, Success, and Failure.

- Prefer the common Loading component for Loading state.
- Do not leave Failure as an empty block.
- If there is no final design yet, leave a `// TODO:` comment explaining the intent or provide a minimal fallback UI.
- In Success state, use UiState already mapped by the ViewModel.

See the example in section 3.

Do not leave Failure empty like this:

```swift
case .failure:
    EmptyView()
```

---

## 13. Apply SwiftLint

Before and after generating code, format according to `.swiftlint.yml`.

- Use 4-space indentation.
- Follow the line length limit.
- End files with a single newline and no trailing whitespace.
- Remove unused imports.
- Use trailing commas in multi-line collection literals.
- If Xcode formatting and SwiftLint conflict, follow the SwiftLint result.

Check command:

```bash
swiftlint lint
```

Auto-fix command:

```bash
swiftlint --fix
```

Build check:

```bash
xcodebuild -scheme momens-ios -destination 'generic/platform=iOS Simulator' build
```

---

## 14. Workflow Before API Integration

Before API integration, implement screens in this order:

1. Define the required `XxxUiState` and `XxxUiModel`.
2. Create fake or state-specific fake state for previews.
3. Make `XxxScreen` receive `XxxUiState` and event closures.
4. Split reusable UI into `Component/`.
5. Check default/empty/long-text/selected states with previews.
6. When connecting the API, map repository responses to `XxxUiState` in the ViewModel.
7. Do not leave fake/mock data inside Views.

### Avoid

```swift
struct SignalScreen: View {
    var body: some View {
        let signals = [
            SignalUiModel(id: 1, title: "Temporary data", summary: "Temporary summary"),
        ]
        SignalContent(signals: signals, onSignalTap: { _ in })
    }
}
```

### Recommended

```swift
struct SignalScreen: View {
    let uiState: SignalUiState
    let onSignalTap: (Int) -> Void

    var body: some View {
        SignalContent(
            signals: uiState.signals,
            onSignalTap: onSignalTap
        )
    }
}
```

Inject fake state in previews.

```swift
#Preview("Signal - Default") {
    SignalScreen(
        uiState: .fake,
        onSignalTap: { _ in }
    )
}
```

---

## 15. Momens Flow Summary

Momens prioritizes this flow:

1. Write `@Observable` ViewModels with constructor injection, assembled in `DIContainer`.
2. Separate screens into View / Screen / Component layers.
3. Let View own the ViewModel, read UiState, and handle SideEffects.
4. Let Screen receive UiState and event closures, then render UI only.
5. Write Component as a reusable UI unit.
6. Represent API state with `UiState<T>`.
7. Separate one-time events such as Navigation, Toast, and Snackbar into SideEffect (`PassthroughSubject` + `.onReceive`).
8. Prefer Momens design system tokens for colors and typography.
9. Navigate with `AppCoordinator` (root), `MainTabCoordinator` (tabs), and per-feature `XxxRoute` + `XxxNavigationStack`.
10. Follow the existing feature folder structure for new files.
11. Even before API integration, define UiState and fake state first.
12. Do not use real dependencies in previews.
