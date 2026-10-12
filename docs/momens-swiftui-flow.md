# Momens SwiftUI Flow

Momens iOS 프로젝트에서 SwiftUI 화면을 작성할 때 따르는 팀 규칙입니다.

일반적인 SwiftUI 작성법보다 Momens의 폴더 구조, MVVM 흐름, 디자인 시스템 사용 방식을 더 구체적으로 맞추기 위한 기준이며, `momens-android`와 1:1로 비교하기 쉽게 맞춰두었습니다.

> AI 에이전트가 참고하는 원본은 `.agents/.skills/momens-ios/references/momens-project-flow.md`(영문)입니다. 내용을 바꿀 때는 두 문서를 함께 수정해주세요.

> 예시는 프로젝트에 이미 있는 `Signal`, `Project`, `Brief`, `SignIn`, `Splash`, `Main` 도메인을 기준으로 작성합니다.

## Android와 대응 관계

| Android | iOS |
| --- | --- |
| Hilt `@HiltViewModel` + `@Inject` | `@Observable` ViewModel + 생성자 주입, `DIContainer`에서 조립 |
| `hiltViewModel()` | `DIContainer.makeXxxViewModel()` → View에서 `@State`로 보관 |
| `StateFlow<UiState<T>>` | `private(set) var uiState: UiState<T>` |
| `MutableSharedFlow<SideEffect>` | `PassthroughSubject<SideEffect, Never>` |
| `collectLatestSideEffect` | `.onReceive(viewModel.sideEffect)` |
| `LaunchedEffect` / `collectAsStateWithLifecycle` | `.task { }` |
| `XxxRoute` | `XxxView` |
| `XxxScreen` | `XxxScreen` |
| `modifier: Modifier = Modifier` | 레이아웃 수정자는 호출부에서 적용 |
| `MomensTheme` | `Core/DesignSystem` 토큰 |
| Typed Navigation + NavController 확장 함수 | `AppCoordinator` / `MainTabCoordinator` + 기능별 `XxxRoute` + `XxxNavigationStack` |
| `ImmutableList` | `struct` + 배열 (값 타입) |
| `@Preview` + `MomensTheme { }` | `#Preview` |
| ktlint + `.editorconfig` | SwiftLint |

---

## 1. ViewModel은 DIContainer에서 생성

Momens의 ViewModel은 `@Observable` 클래스이고, 의존성은 생성자로 받습니다. 조립은 `App/DI/`에서 합니다. Android의 Hilt Module 역할입니다.

프로젝트는 기본 액터 격리가 MainActor로 설정되어 있어서 ViewModel에 `@MainActor`를 따로 붙이지 않아도 메인 스레드에서 동작합니다. 이 빌드 설정을 끄게 되면 모든 ViewModel에 `@MainActor`를 붙여주세요.

### ViewModel 예시

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

### DIContainer 예시

`DIContainer.swift`에는 공용 의존성(네트워크 클라이언트, 저장소, Repository)을 `lazy var`로 둡니다. Swift extension에는 저장 프로퍼티를 추가할 수 없어서, 기능별 `DIContainer+Feature.swift`에는 ViewModel 생성 함수만 둡니다.

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

`DIContainer`는 앱 진입점에서 하나만 만들어 NavigationStack들에 내려줍니다(6번). 전역 싱글톤으로 쓰지 않습니다.

### View 예시

`XxxView` 계층이 ViewModel을 `@State`로 보관합니다. 화면 이동은 여기서 직접 하지 않고, 이 View를 만드는 `XxxNavigationStack`에서 받은 이동 클로저를 호출합니다.

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

`Screen`이나 `Component`에서 ViewModel을 직접 참조하지 않습니다. `DIContainer`도 `Screen`, `Component`에서 접근하지 않고, 앱 진입점과 `XxxNavigationStack`에서만 사용합니다.

---

## 2. View / Screen / Component 역할 분리

가능하면 화면을 `View`, `Screen`, `Component`로 나눕니다.

| 계층 | Android | 역할 |
| --- | --- | --- |
| `XxxView` | `XxxRoute` | ViewModel 보관, UiState 읽기, SideEffect 처리, 화면 이동 클로저 호출 |
| `XxxScreen` | `XxxScreen` / `XxxContent` | 상태와 이벤트 클로저를 받아 UI만 그림 |
| `Component` | `component` | 재사용 UI 단위. ViewModel·화면 이동 직접 참조 금지 |

`XxxRoute`라는 이름은 기능별 네비게이션 enum이 쓰고 있어서, Android의 `XxxRoute` 역할을 iOS에서는 `XxxView`라고 부릅니다.

### View 예시

1번의 `SignalView` 예시를 참고해주세요.

### Screen 예시

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

### Component 예시

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

## 3. 공통 UiState 패턴

API 결과를 보여주는 화면은 `loading`, `success`, `failure`를 명확하게 나눕니다.

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

ViewModel에서는 화면 상태를 `UiState<XxxUiState>`로 감쌉니다.

```swift
private(set) var uiState: UiState<SignalUiState> = .loading
```

View에서는 상태별로 UI를 나눕니다.

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

Repository는 `async throws` 함수로 노출하고, ViewModel에서 `do` / `catch`로 처리합니다.

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

## 4. SideEffect 처리 규칙

화면 이동, Toast, Snackbar, Alert 같은 일회성 이벤트는 `UiState`에 넣지 않고 `SideEffect`로 분리합니다.

```swift
enum SignalSideEffect {
    case navigateToProject(projectId: Int)
    case showSnackbar(message: String)
}
```

ViewModel에서는 `PassthroughSubject`로 내보냅니다. replay가 없는 Android `MutableSharedFlow`와 같은 동작이라, 그 순간 구독 중인 곳에만 전달됩니다.

```swift
let sideEffect = PassthroughSubject<SignalSideEffect, Never>()

func onSignalTap(_ id: Int) {
    sideEffect.send(.navigateToProject(projectId: id))
}
```

`XxxView`에서 `.onReceive`로 처리합니다.

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

SideEffect에 `AsyncStream`을 쓰고 `.task { for await ... }`로 받는 방식은 쓰지 않습니다. 다른 화면으로 이동하면 View가 사라지면서 `.task`가 취소되고, 이때 스트림도 함께 종료됩니다. 그래서 다시 돌아왔을 때 SideEffect를 더 이상 받지 못합니다.

---

## 5. Momens 디자인 시스템 사용

색상, 타이포그래피, 모양은 `Core/DesignSystem`을 먼저 사용합니다.

### 권장

디자인 토큰이 추가되면 합의된 Momens API를 사용합니다. 아래 이름은 예시이고, 실제 이름은 `Core/DesignSystem/Theme`을 따릅니다.

```swift
Text(title)
    .foregroundStyle(MomensColor.gray1000)
    .momensFont(.title1SB18)
```

### 지양

```swift
Text(title)
    .foregroundStyle(.black)
    .font(.system(size: 18, weight: .semibold))
```

토큰 이름은 Android(`MomensTheme.colors.gray1000`, `MomensTheme.typography.title1SB18`)와 맞춰서, 디자이너와 두 플랫폼이 같은 이름으로 소통할 수 있게 합니다.

새 색상이나 타이포그래피가 필요하면 화면에 하드코딩하지 말고 디자인 시스템에 추가하는 걸 먼저 고려해주세요.

---

## 6. Typed Navigation 규칙

화면 이동은 담당 계층별로 나눕니다. 문자열 식별자, 전역 `Route` enum 하나, 화면 안의 `NavigationLink(destination:)`는 쓰지 않습니다.

| 계층 | 타입 | 위치 | 역할 |
| --- | --- | --- | --- |
| 앱 | `AppState` + `AppCoordinator` | `App/` | 루트 화면 결정: `splash`, `signIn`, `onboarding`, `main` |
| 메인 탭 | `MainTab` + `MainTabCoordinator` | `Presentation/Main/` | 선택된 탭과 탭별 타입 경로 |
| 기능 | `XxxRoute` + `XxxNavigationStack` | `Presentation/{Feature}/Navigation/` | 한 탭의 Route case와 각 case가 만드는 View |

### 앱 계층

`SignIn`, `Onboarding`, `Main`은 스택에 쌓는 화면이 아니라 루트에서 서로 교체되는 화면이라 `AppState`의 case로 둡니다.

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

`@main` App이 `appCoordinator.state`를 `switch`해서 맞는 루트 View를 보여줍니다.

### 메인 탭

`MainTabCoordinator`는 선택된 탭과 탭마다 따로 된 타입 경로를 가집니다. 탭을 바꿔도 각 탭의 스택이 유지됩니다.

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

### 기능 계층

각 탭이 자기 `Route` enum과 `NavigationStack` 래퍼를 가집니다.

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
                // SignalRoute의 모든 case에 맞는 View를 여기서 만듭니다.
            }
        }
    }
}
```

규칙:

- Coordinator를 읽고 `DIContainer`로 ViewModel을 만드는 곳은 `XxxNavigationStack` 파일뿐입니다.
- `XxxView`는 이동 클로저만 받고 Coordinator를 직접 건드리지 않습니다.
- `Screen`과 `Component`는 화면 이동을 모릅니다.
- 새 `XxxRoute` case를 추가하면 그 기능의 `navigationDestination`에서 반드시 처리합니다.
- `Core/Navigation`은 여러 기능이 같이 쓰는 이동 보조 코드용입니다. 기능 전용 Route는 여기에 두지 않습니다.

### 지양

```swift
NavigationLink(destination: ProjectView(id: id)) { ... }  // 컴포넌트 안
```

### 권장

```swift
onNavigateToProject(projectId)  // XxxView 안, 보통 SideEffect 처리부
```

---

## 7. 폴더 구조 규칙

새 파일은 기존 기능별 구조를 따릅니다. 폴더 이름은 PascalCase입니다. 경로는 레포 루트 기준이고, 소스 루트는 `momens-ios/`입니다.

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
momens-ios/Core/Network/                                        // EndPoint, 인터셉터, 공통 DTO
momens-ios/Core/Local/                                          // Keychain, UserDefaults
momens-ios/Core/Navigation/                                     // 기능 공용 이동 보조 코드
momens-ios/Core/FCM/
momens-ios/Data/{Feature}/Remote/API/                           // XxxAPI enum (EndPoint)
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

`Project`는 `Task`, `TaskDetail`, `TaskEdit`을 하위 기능으로 묶습니다(`Presentation/Project/Task/...`, `Data/Project/Task/...`). 프로젝트 공용 이동 코드는 `Presentation/Project/Navigation/`에 둡니다.

Android와 달리 기능별 `di/` 폴더가 없습니다. 의존성 연결은 `App/DI/`(`DIContainer.swift` + 기능별 `DIContainer+Feature.swift`)에 두고, Route enum은 각 기능의 `Presentation/{Feature}/Navigation/`에 둡니다.

ViewModel은 기능 폴더 바로 아래에 둡니다. `ViewModel/` 폴더를 따로 만들지 않습니다.

기능 전용 컴포넌트는 해당 기능의 `Component/`에 둡니다.

여러 화면에서 쓰는 컴포넌트는 `Core/DesignSystem/Component/`로 옮기는 걸 고려합니다.

빈 폴더에는 `.gitkeep`이 들어 있습니다. `.gitkeep`은 `project.pbxproj`에서 앱 타깃 제외 목록(`membershipExceptions`)에 등록되어 있어서, 새 `.gitkeep`을 만들면 그 목록에도 추가해야 합니다. 안 하면 "Multiple commands produce '.gitkeep'" 빌드 에러가 납니다. 폴더에 실제 파일이 생기면 `.gitkeep`과 제외 목록 항목을 함께 지웁니다.

프로젝트는 Xcode 동기화 폴더를 사용합니다. 디스크의 올바른 폴더에 파일을 만들면 자동으로 프로젝트에 포함되니, 위의 `.gitkeep` 제외 목록을 빼고는 `momens-ios.xcodeproj/project.pbxproj`를 손으로 수정하지 않습니다.

로컬 저장소 폴더(`Data/{Feature}/Local/DataSource`, `Local/DataSourceImpl`)는 기능에 필요할 때 추가합니다.

---

## 8. API 연동 전 MockData / Preview 규칙

API 연동 전이라도 View 안에 임시 데이터를 하드코딩하지 않습니다.

먼저 `XxxUiState`와 필요한 `XxxUiModel`로 화면 계약을 정의하고, Preview나 임시 UI 확인용 가짜 상태를 만듭니다.

### 규칙

- `Screen`은 가짜 데이터가 아니라 `XxxUiState`를 받습니다.
- 가짜 데이터는 `XxxUiState` extension의 `static let`이나 Preview 근처 private 값으로 둡니다.
- 가짜 데이터는 나중에 ViewModel의 repository 결과 매핑으로 쉽게 바꿀 수 있어야 합니다.
- Preview에서는 ViewModel, Repository, DIContainer, Network를 쓰지 않습니다.
- API 연동 전에도 View / Screen / Component 분리를 지킵니다.
- MockData는 UI 구현과 Preview 확인용입니다. 비즈니스 로직을 대신하면 안 됩니다.

### 예시

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
                title: "API 응답 구조 결정이 필요해요",
                summary: "프로젝트 상세와 브리프 화면에 영향이 있어요."
            ),
            SignalUiModel(
                id: 2,
                title: "오늘 확인할 배포 리스크",
                summary: "토큰 재발급 실패 케이스를 확인해야 해요."
            ),
        ]
    )
}
```

상태가 중요한 화면은 상태별 가짜 값을 따로 만듭니다.

```swift
extension SignalUiState {
    static let fakeNormal = SignalUiState(...)
    static let fakeEmpty = SignalUiState(...)
    static let fakeLongText = SignalUiState(...)
}
```

릴리즈 빌드에 포함되면 안 되는 가짜 값은 `#if DEBUG`로 감쌉니다.

---

## 9. Preview 강화

주요 화면과 재사용 컴포넌트에는 Preview를 작성합니다.

Preview 규칙:

- `#Preview` 매크로를 사용합니다.
- 대상과 상태가 드러나게 이름을 붙입니다.
- 실제 ViewModel, Repository, DIContainer, Network를 쓰지 않습니다.
- 가짜 UiState나 샘플 모델을 씁니다.
- ViewModel이 필요한 `View`는 대신 `Screen`을 Preview합니다.

### 기본 Preview 예시

```swift
#Preview("Signal - Default") {
    SignalScreen(
        uiState: .fake,
        onSignalTap: { _ in }
    )
}
```

### 상태별 Preview 예시

```swift
#Preview("Signal - Empty") {
    SignalScreen(
        uiState: .fakeEmpty,
        onSignalTap: { _ in }
    )
}
```

가능하면 아래 상태를 Preview로 확인합니다.

- 기본 상태
- 빈 상태
- 긴 텍스트 상태
- 리스트 아이템이 많은 상태
- 선택/미선택 상태
- 비활성 상태
- 로딩 상태
- 에러 상태

---

## 10. 값 타입 UI 모델 사용

Swift 배열과 struct는 값 타입이라, Android의 `ImmutableList` 규칙은 iOS에서 이렇게 바뀝니다.

- UI 모델은 class가 아니라 `struct`로 만듭니다.
- 입력 폼처럼 바뀌는 상태가 아니면 UI 모델 프로퍼티는 `let`으로 둡니다.
- UI 모델은 `Equatable`을, 리스트에 쓰이면 `Identifiable`도 채택합니다.
- `XxxUiState`도 `Equatable`을 채택해서 SwiftUI가 불필요한 갱신을 건너뛸 수 있게 합니다.

```swift
struct SignalUiModel: Identifiable, Equatable {
    let id: Int
    let title: String
    let summary: String
}
```

DTO는 상태를 바꾸기 전에 UI 모델로 변환합니다.

```swift
uiState = .success(
    SignalUiState(signals: response.signals.map { $0.toUiModel() })
)
```

Success 상태의 일부만 바꿀 때는 매번 전체를 다시 만들지 말고 `UiState` 헬퍼를 씁니다. Android의 `updateSuccess`와 같은 역할입니다.

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

## 11. 디자인 시스템 컴포넌트 우선 사용

SwiftUI 컨트롤을 직접 꾸미기 전에 Button, TextField, Header, Tag, Loading, Snackbar, BottomSheet 같은 기존 프로젝트 컴포넌트가 있는지 먼저 확인합니다.

바텀시트는 화면마다 `.sheet`를 따로 설정하지 말고, 공용 Momens 바텀시트 컴포넌트(`.sheet` + `.presentationDetents` 기반)를 사용합니다.

새 컴포넌트를 만들 때는 프로젝트 색상, 타이포그래피, 간격 토큰을 우선 사용합니다.

---

## 12. Loading / Failure UI 규칙

API 결과를 보여주는 화면은 Loading, Success, Failure를 명확하게 처리합니다.

- Loading 상태는 공통 Loading 컴포넌트를 우선 사용합니다.
- Failure를 빈 블록으로 두지 않습니다.
- 최종 디자인이 없으면 의도를 적은 `// TODO:` 주석을 남기거나 최소한의 대체 UI를 보여줍니다.
- Success 상태에서는 ViewModel이 이미 매핑한 UiState를 사용합니다.

예시는 3번을 참고해주세요.

Failure를 이렇게 비워두지 않습니다.

```swift
case .failure:
    EmptyView()
```

---

## 13. SwiftLint 적용

코드를 생성하기 전후로 `.swiftlint.yml` 규칙에 맞춰 정리합니다.

- 들여쓰기는 공백 4칸입니다.
- 최대 줄 길이를 지킵니다.
- 파일 끝에 개행 하나를 두고, 줄 끝 공백을 남기지 않습니다.
- 쓰지 않는 import를 지웁니다.
- 여러 줄 배열·딕셔너리 리터럴에는 trailing comma를 붙입니다.
- Xcode 자동 포맷과 SwiftLint가 충돌하면 SwiftLint 결과를 따릅니다.

검사 명령:

```bash
swiftlint lint
```

자동 수정 명령:

```bash
swiftlint --fix
```

빌드 확인:

```bash
xcodebuild -scheme momens-ios -destination 'generic/platform=iOS Simulator' build
```

---

## 14. API 연동 전 작업 순서

API 연동 전에는 아래 순서로 화면을 구현합니다.

1. 필요한 `XxxUiState`와 `XxxUiModel`을 정의합니다.
2. Preview용 가짜 상태, 상태별 가짜 상태를 만듭니다.
3. `XxxScreen`이 `XxxUiState`와 이벤트 클로저를 받게 만듭니다.
4. 재사용 UI를 `Component/`로 분리합니다.
5. 기본/빈/긴 텍스트/선택 상태를 Preview로 확인합니다.
6. API를 연결할 때 ViewModel에서 repository 결과를 `XxxUiState`로 매핑합니다.
7. View 안에 가짜 데이터를 남기지 않습니다.

### 지양

```swift
struct SignalScreen: View {
    var body: some View {
        let signals = [
            SignalUiModel(id: 1, title: "임시 데이터", summary: "임시 요약"),
        ]
        SignalContent(signals: signals, onSignalTap: { _ in })
    }
}
```

### 권장

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

Preview에서는 가짜 상태를 주입합니다.

```swift
#Preview("Signal - Default") {
    SignalScreen(
        uiState: .fake,
        onSignalTap: { _ in }
    )
}
```

---

## 15. Momens 흐름 요약

Momens는 아래 흐름을 우선합니다.

1. ViewModel은 `@Observable` + 생성자 주입으로 만들고, `DIContainer`에서 조립합니다.
2. 화면을 View / Screen / Component로 나눕니다.
3. View는 ViewModel을 가지고, UiState를 읽고, SideEffect를 처리합니다.
4. Screen은 UiState와 이벤트 클로저를 받아 UI만 그립니다.
5. Component는 재사용 UI 단위로 작성합니다.
6. API 상태는 `UiState<T>`로 표현합니다.
7. 화면 이동, Toast, Snackbar 같은 일회성 이벤트는 SideEffect(`PassthroughSubject` + `.onReceive`)로 분리합니다.
8. 색상과 타이포그래피는 Momens 디자인 시스템 토큰을 우선 사용합니다.
9. 화면 이동은 `AppCoordinator`(루트), `MainTabCoordinator`(탭), 기능별 `XxxRoute` + `XxxNavigationStack`으로 합니다.
10. 새 파일은 기존 기능 폴더 구조를 따릅니다.
11. API 연동 전에도 UiState와 가짜 상태를 먼저 정의합니다.
12. Preview에서 실제 의존성을 쓰지 않습니다.
