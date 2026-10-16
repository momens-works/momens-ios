---
name: momens-ios
description: Use this skill when creating, modifying, or reviewing Swift and SwiftUI code in the Momens iOS project. Applies to SwiftUI Views, @Observable ViewModel state, MVVM, DIContainer, NavigationStack/Coordinator, Preview, design system usage, SwiftLint, and Momens team conventions.
---

# Momens iOS Skill

This skill guides agents to write and review Swift and SwiftUI code according to Momens project conventions.

Use this skill when the task involves:

- Swift code in the Momens iOS project
- SwiftUI UI
- SwiftUI Views and components
- `@Observable` ViewModel
- MVVM structure
- `UiState<T>` or SideEffect (`PassthroughSubject`)
- Swift Concurrency (`async`/`await`, `Task`, `.task`)
- DIContainer / constructor injection
- NavigationStack, `AppCoordinator`, `MainTabCoordinator`, `XxxRoute`
- View / Screen / Component separation
- `#Preview`
- Design system
- SwiftLint
- UI refactoring
- SwiftUI code review
- Porting a feature from `momens-android`

---

## Reference Files

Before making SwiftUI-related changes, read the relevant reference files.

For general SwiftUI rules, read:

```text
references/swiftui-basic-flow.md
```

For Momens-specific project rules, read:

```text
references/momens-project-flow.md
```

---

## Core Rules

Always follow these rules:

1. Keep UI and business logic separated.
2. Keep screen state in the ViewModel.
3. Use `@Observable` ViewModel properties (`private(set) var uiState`) for persistent UI state.
4. Use `PassthroughSubject<SideEffect, Never>` consumed with `.onReceive` for one-time events.
5. Follow State Down, Event Up.
6. Prefer stateless Views.
7. Let the caller apply layout modifiers to reusable Views.
8. Do not force `.frame(maxWidth: .infinity, maxHeight: .infinity)` or outer padding inside reusable components.
9. Do not pass ViewModel or a coordinator into reusable components.
10. Start async work with `.task { }` in View-level code, not `onAppear { Task { } }`.
11. Separate View, Screen, and Component responsibilities.
12. Create ViewModels through `DIContainer` and own them with `@State` in the View layer.
13. Use the Momens design system before raw SwiftUI colors, fonts, and controls.
14. Use `#Preview` with fake UiState or sample models.
15. Do not use real ViewModel, Repository, DIContainer, or Network in Preview.
16. Make UI models `struct`s that conform to `Equatable` (and `Identifiable` when listed).
17. Use stable `id`s in `ForEach`, `List`, and lazy stacks.
18. Avoid exposing DTO (API response) models directly to UI.
19. Handle Loading, Success, Failure states clearly.
20. Follow SwiftLint formatting.

---

## View / Screen / Component Rule

Prefer this structure:

```text
XxxView
XxxScreen
Component/XxxComponent
```

`XxxRoute` is the per-feature navigation enum (`Presentation/{Feature}/Navigation/XxxRoute.swift`), so the Android `XxxRoute` role is named `XxxView` on iOS.

Responsibilities:

### `XxxView`

- Owns the ViewModel (`@State private var viewModel`)
- Reads UiState from the ViewModel
- Consumes SideEffect
- Calls navigation closures received from `XxxNavigationStack` (never reads a coordinator itself)
- Handles View-level lifecycle logic (`.task`, `.onChange`)

### `XxxScreen`

- Receives UiState and event closures
- Draws UI only
- Does not know ViewModel
- Does not know navigation or coordinators

### `Component`

- Reusable UI unit
- Receives data and event closures
- Does not directly reference ViewModel, Repository, or a coordinator
- Leaves size and position to the caller

---

## When Creating a New Screen

Follow this order:

1. Define `XxxUiState`.
2. Define necessary `XxxUiModel`.
3. Add fake state for Preview.
4. Create `XxxView`.
5. Create `XxxScreen`.
6. Split reusable UI into `Component/`.
7. Add `#Preview`.
8. Add an `XxxRoute` case and connect it in that feature's `XxxNavigationStack` (`navigationDestination`).
9. Connect API later through ViewModel and repository mapping.
10. Remove temporary mock data from View bodies.

---

## When Reviewing Code

Check:

- Is state owned by the ViewModel?
- Is UI stateless where possible?
- Is business logic outside Views?
- Is the ViewModel `@Observable` and isolated to the main actor?
- Does the View start async work with `.task`?
- Are one-time events separated into SideEffect?
- Are reusable components free from ViewModel and coordinators?
- Does the caller control layout?
- Is `.frame(maxWidth: .infinity, maxHeight: .infinity)` avoided inside components?
- Is the Momens design system used?
- Are common design system components reused?
- Are previews using fake states?
- Are UI models value types (`struct`) and `Equatable`?
- Are list `id`s stable?
- Are Loading and Failure states handled?
- Are SwiftLint rules followed?

---

## Output Style

When changing code:

1. Briefly explain what files changed.
2. Explain how the change follows Momens SwiftUI rules.
3. Mention any assumptions.
4. Mention any checks that should be run.

When reviewing code:

1. List critical issues first.
2. Then major issues.
3. Then minor issues.
4. Include file paths and symbols.
5. Suggest the smallest practical fix.
6. Avoid vague style-only comments.
