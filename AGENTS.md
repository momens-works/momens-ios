# Momens AI Agent Guide

This project is an iOS application built with SwiftUI.

When an AI agent writes or modifies iOS or SwiftUI-related code, it must follow the Momens conventions documented in this repository.

Codex should use the `momens-ios` skill for iOS/SwiftUI work and the
`momens-workflow` skill for task, branch, commit, and PR workflow. Other agents,
including Claude, should read the same skill and reference files directly.

The Android app (`momens-android`) is the reference implementation. When porting a
feature, read the matching Android feature first and keep the same layering and naming
unless an iOS convention below says otherwise.

## Project Context

- Language: Swift
- UI: SwiftUI
- Minimum target: iOS 17
- Architecture: MVVM
- State management: `@Observable` ViewModel + `UiState<T>`
- One-time events: `PassthroughSubject<SideEffect, Never>` + `.onReceive`
- Concurrency: Swift Concurrency (`async`/`await`, `Task`, `actor`)
- Dependency injection: Constructor injection assembled in `App/DI/` (`DIContainer.swift` + `DIContainer+Feature.swift`)
- Navigation: `AppCoordinator` (`AppState`: splash / signIn / onboarding / main) → `MainTabCoordinator` (per-tab typed paths) → per-feature `XxxRoute` + `XxxNavigationStack`
- Networking: Alamofire (`EndPoint` protocol, `XxxAPI` enums, token refresh interceptor)
- Package manager: Swift Package Manager
- Code style: SwiftLint (`.swiftlint.yml`)

## Where To Start

Before making changes, inspect the relevant feature folder and follow the existing implementation style.

For SwiftUI screen work, prefer this structure:

- `XxxView`: Owns the ViewModel, observes UiState, handles SideEffects, and calls navigation closures provided by `XxxNavigationStack`.
- `XxxScreen`: Receives UiState and event closures, then renders UI only.
- `Component`: Contains reusable UI units.

## Required Guide

For iOS and SwiftUI work, use this guide:

```text
.agents/.skills/momens-ios/SKILL.md
```

For Momens task, branch, commit, PR, and GitHub migration workflow, use this guide:

```text
.agents/.skills/momens-workflow/SKILL.md
```

Use these documents as the source of truth for SwiftUI work:

```text
.agents/.skills/momens-ios/references/swiftui-basic-flow.md
.agents/.skills/momens-ios/references/momens-project-flow.md
```

## Basic Rules

- Check the existing project structure and naming before editing.
- Do not modify files outside the requested scope.
- Avoid unnecessarily large refactors.
- Keep screen state in the ViewModel.
- Keep SwiftUI Views focused on rendering state.
- Send events upward through closures.
- Do not reference ViewModel or coordinators directly from reusable components.
- Prefer the design system (`Core/DesignSystem`) over raw SwiftUI styling.
- Follow SwiftLint rules.
- Do not edit `.pbxproj` by hand unless the task explicitly requires it. The one routine exception is adding a new `.gitkeep` to the `membershipExceptions` list (see `momens-project-flow.md`, section 7).
- Do not commit secrets (`Config/Secrets.xcconfig`, `GoogleService-Info.plist`).

## Pull Request Rules

When an AI agent writes a PR title, use this format:

```text
[TYPE/MOM-0000] Summary
```

`TYPE` must be uppercase.

Example:

```text
[FEAT/MOM-0735] FileListItem 컴포넌트 구현
```

Work management is handled in Momens. Create and reference Momens tasks
(`MOM-0000`) instead of GitHub issues for new work.

## Current Project Layout

```text
momens-ios/                      # repository root
├── AGENTS.md
├── CLAUDE.md
├── .agents/
│   └── .skills/
│       ├── momens-ios/
│       │   ├── SKILL.md
│       │   └── references/
│       │       ├── swiftui-basic-flow.md
│       │       └── momens-project-flow.md
│       └── momens-workflow/
│           └── SKILL.md
├── .codex/
│   ├── config.toml
│   └── agents/                  # *.toml
├── .claude/
│   └── agents/                  # *.md
├── .github/
│   ├── pull_request_template.md
│   └── ISSUE_TEMPLATE/
├── .coderabbit.yaml            # CodeRabbit review config
├── Config/                      # xcconfig files (Secrets.xcconfig is git-ignored)
├── docs/
├── momens-ios/                  # app source
│   ├── App/                     # entry point, AppCoordinator, DI/
│   ├── Core/                    # Common, DesignSystem, FCM, Local, Navigation, Network
│   ├── Data/                    # {Feature}/{Model, Remote, Repository, RepositoryImpl}
│   ├── Presentation/            # {Feature}/{View, Screen, ViewModel, State, Component, Model, Navigation}
│   └── Resources/               # Assets.xcassets
└── momens-ios.xcodeproj
```

Not added yet (do not assume they exist): `.swiftlint.yml`, `Config/*.xcconfig`, a test target, CI workflows.
