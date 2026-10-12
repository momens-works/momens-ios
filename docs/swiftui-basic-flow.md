# SwiftUI Basic Flow

대부분의 SwiftUI 프로젝트에서 따르는 기본 작성 흐름입니다.

Momens 전용 규칙이 아니라, 안정적이고 재사용 가능하며 유지보수하기 쉬운 SwiftUI UI를 위한 일반 원칙을 정리한 문서입니다.

> AI 에이전트가 참고하는 원본은 `.agents/.skills/momens-ios/references/swiftui-basic-flow.md`(영문)입니다. 내용을 바꿀 때는 두 문서를 함께 수정해주세요.

## 목차

1. State Down, Event Up
2. View는 가능하면 Stateless로
3. 레이아웃은 호출부가 결정
4. 비동기 작업은 `.task`로 시작
5. UiState와 SideEffect 분리
6. Preview에서 실제 의존성 사용 금지
7. 리스트에는 안정적인 id 사용
8. UI 모델을 명시적으로 정의
9. 요약

---

## 1. State Down, Event Up

SwiftUI 화면은 **상태는 아래로, 이벤트는 위로** 흐르게 작성합니다.

View는 상위 계층에서 상태를 받아 그대로 그리고, 탭·입력·선택 같은 사용자 동작은 클로저로 위에 전달합니다.

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

```swift
struct SignalContent: View {
    let signals: [SignalUiModel]
    let onSignalTap: (Int) -> Void

    var body: some View {
        LazyVStack {
            ForEach(signals) { signal in
                SignalCard(
                    title: signal.title,
                    summary: signal.summary,
                    onTap: { onSignalTap(signal.id) }
                )
            }
        }
    }
}
```

### 지양

```swift
struct SignalCard: View {
    let signal: SignalUiModel
    @Environment(MainTabCoordinator.self) private var coordinator

    var body: some View {
        Button {
            coordinator.projectPath.append(.task(projectId: signal.id))
        } label: {
            Text(signal.title)
        }
    }
}
```

재사용 컴포넌트 안에서 직접 화면 이동을 하지 않습니다. 컴포넌트가 특정 네비게이션 구현에 묶여서 재사용과 Preview가 어려워집니다.

컴포넌트 안의 `NavigationLink(destination:)`도 같은 문제가 있으니, 이벤트를 위로 올려주세요.

---

## 2. View는 가능하면 Stateless로

View는 화면 상태를 직접 들고 있지 않고, 전달받은 상태를 그리는 데 집중합니다.

### 권장

```swift
struct SignInTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
    }
}
```

상태의 원본이 ViewModel이라면 값과 변경 클로저를 넘기거나, 호출부에서 만든 `Binding`을 넘깁니다.

### 지양

```swift
struct SignInTextField: View {
    @State private var text = ""

    var body: some View {
        TextField("이메일", text: $text)
    }
}
```

이메일, 비밀번호, 선택값, 서버 데이터 같은 화면 상태는 보통 ViewModel이 가집니다.

메뉴 펼침, 임시 선택, 포커스(`@FocusState`), 애니메이션 상태처럼 UI에만 필요한 로컬 상태는 `@State`를 써도 됩니다.

---

## 3. 레이아웃은 호출부가 결정

SwiftUI에서는 수정자(modifier)를 View 바깥에서 붙입니다. 재사용 View는 크기·위치·바깥 여백을 내부에서 정하지 않고 호출부에 맡깁니다.

Compose에서 `modifier: Modifier = Modifier`를 열어두는 것과 같은 규칙입니다.

### 권장

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

### 사용 예

```swift
SignalCard(
    title: signal.title,
    summary: signal.summary,
    onTap: { onSignalTap(signal.id) }
)
.frame(maxWidth: .infinity, alignment: .leading)
.padding(.horizontal, 20)
```

컴포넌트 계약상 꼭 필요한 경우가 아니면, 재사용 컴포넌트 내부에 `.frame(maxWidth: .infinity, maxHeight: .infinity)`, 고정 `.frame(width:height:)`, 바깥 `.padding()`을 강제하지 않습니다.

화면 전체를 채우는 건 화면 레벨에서는 괜찮지만, 작은 재사용 컴포넌트 안에서는 피합니다.

---

## 4. 비동기 작업은 `.task`로 시작

View에서 데이터 로딩 같은 비동기 작업을 시작할 때는 `onAppear { Task { } }` 대신 `.task { }`를 씁니다.

### 권장

```swift
.task {
    await viewModel.loadSignals()
}
```

`.task`는 View가 사라지면 자동으로 취소됩니다. Compose의 `collectAsStateWithLifecycle()`처럼 생명주기를 따르는 방식입니다.

### 지양

```swift
.onAppear {
    Task {
        await viewModel.loadSignals()
    }
}
```

이렇게 만든 `Task`는 View가 사라져도 계속 실행돼서 누수가 생기기 쉽습니다.

---

## 5. UiState와 SideEffect 분리

화면에 계속 보여야 하는 상태는 `UiState`로 둡니다.

한 번만 일어나는 이벤트는 `SideEffect`로 둡니다.

### UiState에 적합한 값

- 화면에 보이는 데이터
- 로딩 상태
- 빈 상태
- 에러 상태
- 선택값
- 입력값

### SideEffect에 적합한 값

- 화면 이동
- Toast
- Snackbar
- Alert / Sheet 표시
- 일회성 메시지
- 권한 요청
- 외부 앱·URL 열기

### 예시

```swift
enum SignalSideEffect {
    case navigateToProject(projectId: Int)
    case showSnackbar(message: String)
}
```

화면 이동이나 Snackbar를 `UiState`에 넣으면, 화면이 다시 그려지거나 재진입할 때 이벤트가 또 실행될 수 있습니다.

---

## 6. Preview에서 실제 의존성 사용 금지

Preview에서는 ViewModel, Repository, Network, DI 컨테이너를 쓰지 않습니다.

Preview는 UI를 확인하는 용도이므로 가짜 상태나 샘플 모델을 사용합니다.

### 권장

```swift
#Preview {
    SignalScreen(
        uiState: .fake,
        onSignalTap: { _ in }
    )
}
```

### 지양

```swift
#Preview {
    SignalView(
        viewModel: DIContainer().makeSignalViewModel()
    )
}
```

UI에 필요한 상태만 Preview에 넘겨주세요.

---

## 7. 리스트에는 안정적인 id 사용

`ForEach`, `List`, `LazyVStack`, `LazyHStack`, 그리드를 쓸 때는 항목마다 고정된 id를 줍니다.

### 권장

```swift
struct SignalUiModel: Identifiable, Equatable {
    let id: Int
    let title: String
    let summary: String
}

ForEach(uiState.signals) { signal in
    SignalCard(
        title: signal.title,
        summary: signal.summary,
        onTap: { onSignalTap(signal.id) }
    )
}
```

### 지양

```swift
ForEach(uiState.signals.indices, id: \.self) { index in
    SignalCard(...)
}
```

```swift
ForEach(titles, id: \.self) { title in
    Text(title)
}
```

인덱스를 id로 쓰면 항목이 추가·삭제·재정렬될 때 애니메이션과 상태가 꼬입니다. `id: \.self`는 값이 절대 중복되지 않을 때만 안전합니다.

렌더링할 때마다 실행되는 계산 프로퍼티나 매퍼 안에서 `UUID()`를 새로 만들지 마세요. 같은 항목이면 id도 항상 같아야 합니다.

---

## 8. UI 모델을 명시적으로 정의

API 응답 모델(DTO)을 SwiftUI UI에 직접 넘기지 않습니다.

화면 전용 `UiState`와 `UiModel`을 따로 정의합니다.

### 권장

```swift
struct SignalUiState: Equatable {
    var userName: String = ""
    var signals: [SignalUiModel] = []
}

struct SignalUiModel: Identifiable, Equatable {
    let id: Int
    let title: String
    let summary: String
}
```

### 지양

```swift
struct SignalScreen: View {
    let response: SignalResponse

    var body: some View {
        Text(response.data.project.signal.title)
    }
}
```

응답 구조가 UI까지 내려오면 서버 변경이 화면 코드로 번집니다. ViewModel이나 매퍼에서 UI 모델로 바꾼 뒤 그려주세요.

Swift 배열은 값 타입이라 Kotlin `ImmutableList` 같은 별도 불변 컬렉션은 필요 없습니다. UI 모델은 `let` 프로퍼티를 가진 `struct`로 둡니다.

---

## 9. 요약

SwiftUI 기본 흐름:

1. 상태는 상위 계층에서 관리합니다.
2. 상태를 View로 내려줍니다.
3. 이벤트는 클로저로 올립니다.
4. 재사용 컴포넌트에서 ViewModel이나 Coordinator를 참조하지 않습니다.
5. 레이아웃은 호출부가 결정합니다.
6. 비동기 작업은 `.task`로 시작합니다.
7. `UiState`와 `SideEffect`를 분리합니다.
8. Preview에는 가짜 상태를 씁니다.
9. 리스트에는 고정된 id를 씁니다.
10. DTO를 UI에 직접 넘기지 않습니다.
