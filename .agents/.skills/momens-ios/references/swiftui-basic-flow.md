# SwiftUI Basic Flow

This document defines the baseline SwiftUI flow that should be followed in most SwiftUI projects.

These rules are not specific to Momens. They describe general principles for writing stable, reusable, and maintainable SwiftUI UI.

## Contents

1. State Down, Event Up
2. Keep Views Stateless When Possible
3. Let The Caller Control Layout
4. Start Async Work With `.task`
5. Separate UiState And SideEffect
6. Do Not Use Real Dependencies In Preview
7. Use Stable IDs For Lists
8. Define Explicit UI Models
9. Summary

---

## 1. State Down, Event Up

SwiftUI screens should follow **state down, event up**.

Views should receive state from a higher layer and render UI from that state. User actions such as taps, input changes, and selections should be sent upward through closures.

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

### Avoid

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

Do not perform navigation directly inside reusable components. Doing so couples the component to a specific navigation implementation and makes reuse and previewing harder.

`NavigationLink(destination:)` inside a reusable component has the same problem. Send the event upward instead.

---

## 2. Keep Views Stateless When Possible

Views should usually avoid owning screen state. They should focus on rendering the state they receive.

### Recommended

```swift
struct SignInTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
    }
}
```

When the source of truth is a ViewModel, pass a value and a change closure, or a `Binding` created by the caller.

### Avoid

```swift
struct SignInTextField: View {
    @State private var text = ""

    var body: some View {
        TextField("이메일", text: $text)
    }
}
```

Screen state such as email, password, selected values, and server data should usually be owned by the ViewModel.

Local UI-only state, such as menu expansion, temporary selection, focus state (`@FocusState`), or animation state, may use `@State`.

---

## 3. Let The Caller Control Layout

In SwiftUI, modifiers are applied from outside the View. Reusable Views should let the caller decide size, position, and outer spacing instead of forcing those decisions inside the component.

This is the SwiftUI equivalent of exposing `modifier: Modifier = Modifier` in Compose.

### Recommended

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

### Usage

```swift
SignalCard(
    title: signal.title,
    summary: signal.summary,
    onTap: { onSignalTap(signal.id) }
)
.frame(maxWidth: .infinity, alignment: .leading)
.padding(.horizontal, 20)
```

Avoid forcing `.frame(maxWidth: .infinity, maxHeight: .infinity)`, fixed `.frame(width:height:)`, or outer `.padding()` inside reusable components unless the component contract explicitly requires it.

Filling the whole space is acceptable at the screen level, but it should usually be avoided inside small reusable components.

---

## 4. Start Async Work With `.task`

When a View needs to start async work (loading data, consuming a stream), prefer `.task { }` over `onAppear { Task { } }`.

### Recommended

```swift
.task {
    await viewModel.loadSignals()
}
```

`.task` is cancelled automatically when the View disappears, which makes it the lifecycle-aware choice in SwiftUI.

### Avoid

```swift
.onAppear {
    Task {
        await viewModel.loadSignals()
    }
}
```

An unstructured `Task` keeps running after the View disappears and is easy to leak.

---

## 5. Separate UiState And SideEffect

State that must remain visible on screen should be modeled as `UiState`.

One-time events should be modeled as `SideEffect`.

### Good UiState Values

- Data shown on screen
- Loading state
- Empty state
- Error state
- Selected values
- Input values

### Good SideEffect Values

- Navigation
- Toast
- Snackbar
- Alert / sheet display
- One-time messages
- Permission requests
- Opening external apps or URLs

### Example

```swift
enum SignalSideEffect {
    case navigateToProject(projectId: Int)
    case showSnackbar(message: String)
}
```

Navigation and Snackbar events should not be stored in `UiState`, because re-rendering or screen re-entry can accidentally trigger them again.

---

## 6. Do Not Use Real Dependencies In Preview

Previews should not use ViewModel, Repository, Network, or the DI container.

Previews exist to inspect UI, so they should use fake state or sample models.

### Recommended

```swift
#Preview {
    SignalScreen(
        uiState: .fake,
        onSignalTap: { _ in }
    )
}
```

### Avoid

```swift
#Preview {
    SignalView(
        viewModel: DIContainer().makeSignalViewModel()
    )
}
```

Pass only the state needed by the UI into previews.

---

## 7. Use Stable IDs For Lists

When using `ForEach`, `List`, `LazyVStack`, `LazyHStack`, or grids, provide stable identity.

### Recommended

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

### Avoid

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

Index-based identity breaks animations and state when items are inserted, removed, or reordered. `id: \.self` is only safe when values are guaranteed to be unique.

Do not create a new `UUID()` inside a computed property or mapper that runs on every render. The `id` must stay the same for the same item.

---

## 8. Define Explicit UI Models

Do not expose API response models (DTOs) directly to SwiftUI UI.

Define screen-specific `UiState` and `UiModel` types instead.

### Recommended

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

### Avoid

```swift
struct SignalScreen: View {
    let response: SignalResponse

    var body: some View {
        Text(response.data.project.signal.title)
    }
}
```

If API response structures reach UI code directly, server-side changes can leak into the presentation layer. Map responses into UI models in the ViewModel or mapper layer before rendering.

Swift arrays are value types, so a separate immutable collection type (like Kotlin `ImmutableList`) is not needed. Keep UI models as `struct`s with `let` properties.

---

## 9. Summary

SwiftUI basic flow:

1. Manage state in the upper layer.
2. Pass state down to Views.
3. Send events upward through closures.
4. Do not reference ViewModel or a coordinator from reusable components.
5. Let the caller control layout.
6. Start async work with `.task`.
7. Separate `UiState` and `SideEffect`.
8. Use fake state in previews.
9. Use stable `id`s in lists.
10. Do not expose DTOs directly to UI.
