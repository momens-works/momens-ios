# Agent Configs

Momens iOS 프로젝트에서 사용하는 AI 에이전트 설정을 설명합니다.

이 문서는 설정 파일을 직접 읽지 않아도, 어떤 에이전트를 언제 어떻게 사용하면 되는지 알 수 있도록 정리한 사용자용 가이드입니다.

## 문서 구조

```text
AGENTS.md                 # 모든 에이전트 공통 가이드 (Codex는 자동으로 읽음)
CLAUDE.md                 # Claude Code 진입점. @AGENTS.md 로 공통 가이드를 불러옴

.codex/
├── config.toml
└── agents/
    ├── momens-explorer.toml
    ├── momens-reviewer.toml
    ├── code-reviewer.toml
    └── pr-writer.toml

.claude/agents/
├── momens-explorer.md
├── momens-reviewer.md
├── code-reviewer.md
└── pr-writer.md
```

Codex와 Claude 폴더에는 같은 이름의 에이전트가 들어 있고, 지시 내용(본문)도 동일합니다.

파일 형식만 다릅니다.

- Codex: TOML (`developer_instructions`에 지시 내용)
- Claude Code: YAML frontmatter가 있는 Markdown (`---` 아래 본문이 지시 내용)

Claude Code는 `.claude/agents/`의 `.md` 파일만 서브에이전트로 인식합니다. TOML 파일은 읽지 않으므로 Android 레포처럼 `.claude/`에 TOML을 두면 동작하지 않습니다.

에이전트 지시 내용을 수정할 때는 `.codex/agents/*.toml`과 `.claude/agents/*.md`를 함께 수정해주세요.

## 에이전트 목록

| 에이전트 | Codex 이름 | Claude 이름 | 목적 |
| --- | --- | --- | --- |
| explorer | `momens_explorer` | `momens-explorer` | 구현 전에 관련 코드 구조와 흐름을 읽기 전용으로 탐색 |
| reviewer | `momens_reviewer` | `momens-reviewer` | Momens SwiftUI 규칙을 기준으로 화면 구현을 리뷰 |
| code reviewer | `code_reviewer` | `code-reviewer` | PR 리뷰처럼 correctness, architecture, concurrency, test risk를 넓게 점검 |
| PR writer | `pr_writer` | `pr-writer` | PR 템플릿에 맞춰 현재 변경사항의 PR 본문을 작성 |

Codex는 이름에 `_`를, Claude Code는 `-`를 사용합니다.

네 에이전트는 모두 읽기 전용입니다.

파일을 직접 수정하지 않고, 코드 구조를 설명하거나 리뷰 의견을 제공합니다.

## 선택 기준

| 상황 | 사용할 에이전트 |
| --- | --- |
| 어떤 파일을 봐야 할지 모르겠음 | explorer |
| 구현 전에 기존 화면 흐름을 알고 싶음 | explorer |
| Android 화면을 iOS로 옮기기 전에 대응 구조를 파악하고 싶음 | explorer |
| SwiftUI 화면이 Momens 규칙을 지키는지 보고 싶음 | reviewer |
| ViewModel, UiState, SideEffect 구조를 점검하고 싶음 | reviewer |
| PR 올리기 전 버그 가능성과 테스트 누락을 보고 싶음 | code reviewer |
| 변경사항 전체를 더 엄격하게 리뷰하고 싶음 | code reviewer |
| PR 템플릿에 맞는 본문 초안이 필요함 | PR writer |
| 변경사항을 리뷰어가 읽기 좋은 PR 설명으로 정리하고 싶음 | PR writer |

## 기본 사용 흐름

새 기능이나 화면을 작업할 때는 보통 다음 순서로 사용합니다.

```text
1. explorer
   기존 구조, 관련 파일, 상태 흐름, navigation 흐름을 파악합니다.
   Android에서 옮겨오는 기능이면 대응되는 momens-android 파일도 함께 확인합니다.

2. 구현
   일반 작업 에이전트나 작업자가 코드를 수정합니다.

3. reviewer
   Momens SwiftUI 규칙을 기준으로 화면 구조를 점검합니다.

4. code reviewer
   PR 리뷰처럼 버그 가능성, architecture 문제, concurrency 문제, missing tests를 확인합니다.

5. PR writer
   `.github/pull_request_template.md` 형식에 맞춰 PR 본문을 작성합니다.
```

항상 네 단계를 모두 거칠 필요는 없습니다.

작은 UI 수정이라면 reviewer만으로 충분할 수 있고, 단순 구조 파악이 목적이면 explorer만 사용해도 됩니다.

PR 본문만 필요하다면 PR writer만 사용해도 됩니다.

## 요청 방법

에이전트를 사용할 때는 에이전트 이름과 확인할 범위를 같이 말합니다.

좋은 요청에는 보통 다음 정보가 들어갑니다.

- 화면 이름 또는 기능 이름
- 관련 폴더나 파일 경로
- 보고 싶은 관점
- 현재 고민되는 부분

## 요청 예시

아래 예시는 Claude Code 이름 기준입니다. Codex에서는 `momens_explorer`처럼 `_` 이름을 사용하면 됩니다.

### 구현 전 탐색

```text
momens-explorer로 SignIn 화면 구조를 탐색해줘.
관련 파일, ViewModel, View, Screen, navigation 흐름을 정리해줘.
```

```text
momens-explorer로 momens-ios/Presentation/Project 폴더를 봐줘.
데이터가 repository에서 UI까지 어떻게 흐르는지 알려줘.
```

### SwiftUI 규칙 리뷰

```text
momens-reviewer로 현재 변경한 SwiftUI 화면을 리뷰해줘.
View / Screen / Component 분리, UiState, SideEffect, Preview 위주로 봐줘.
```

```text
momens-reviewer로 SignIn 관련 변경사항을 봐줘.
Momens SwiftUI 규칙을 어긴 부분만 중요도 순으로 알려줘.
```

### 최종 코드 리뷰

```text
code-reviewer로 현재 git diff를 PR 리뷰처럼 봐줘.
Critical, Major, Minor 순서로 정리하고 missing tests도 알려줘.
```

```text
code-reviewer로 Project 폴더 변경사항을 리뷰해줘.
버그 가능성, architecture 문제, navigation 문제, concurrency 문제를 우선해서 봐줘.
```

### PR 본문 작성

```text
pr-writer로 현재 git diff를 기준으로 PR 본문 작성해줘.
관련 Momens 티켓은 MOM-0752이고, 테스트는 아직 안 돌렸어.
```

```text
pr-writer로 현재 변경사항을 `.github/pull_request_template.md`에 맞춰 정리해줘.
모르는 항목은 추측하지 말고 확인 필요로 남겨줘.
```

## 에이전트별 역할

### explorer

구현 전에 코드베이스를 읽고 관련 구조를 정리합니다.

주로 확인하는 것:

- 관련 파일과 폴더
- View, Screen, ViewModel, XxxRoute case, repository 위치
- UiState가 만들어지고 전달되는 흐름
- 이벤트가 클로저나 SideEffect로 올라가는 흐름
- Android에서 옮겨오는 기능이면 대응되는 momens-android 파일과 의도적으로 다른 부분
- 수정해야 할 가능성이 있는 파일

결과는 보통 관련 파일, 현재 흐름, 중요한 symbol, 위험하거나 불명확한 점, 다음에 볼 파일 순서로 정리됩니다.

### reviewer

Momens iOS SwiftUI 규칙을 기준으로 구현을 리뷰합니다.

주로 확인하는 것:

- View / Screen / Component 분리
- ViewModel의 상태 소유 (`@Observable`, View에서 `@State`로 보관)
- `.task`로 비동기 작업 시작
- UiState와 SideEffect 분리
- 재사용 컴포넌트가 크기·바깥 여백을 호출부에 맡기는지
- ViewModel 또는 Coordinator 직접 참조 여부
- Preview와 디자인 시스템 사용

SwiftUI 화면 구현 후 가장 먼저 돌려보기 좋은 리뷰 에이전트입니다.

### code reviewer

PR 리뷰에 가까운 넓은 관점으로 변경사항을 점검합니다.

주로 확인하는 것:

- 실제 버그 가능성
- architecture와 책임 분리 문제
- 생명주기, navigation, 불필요한 화면 갱신 위험
- concurrency (메인 액터, Task 취소, 데이터 경쟁)
- 강제 언래핑(`!`), `try!` 등 크래시 가능성
- 테스트 또는 수동 검증 누락
- SwiftLint 규칙
- 시크릿 파일이나 `project.pbxproj` 의도치 않은 변경

단순 컨벤션 확인보다 최종 점검에 더 적합합니다.

### PR writer

PR 템플릿에 맞춰 현재 변경사항의 PR 본문을 작성합니다.

주로 확인하는 것:

- `.github/pull_request_template.md`
- 현재 `git diff`
- 현재 브랜치명에 포함된 Momens 티켓 번호
- 변경된 파일과 폴더
- 사용자에게 보이는 변경사항
- 내부 구조 변경이나 문서 변경
- 실제로 실행된 테스트 또는 확인되지 않은 검증 항목

PR 본문을 작성할 때 관련 작업은 브랜치명의 `MOM-0000` 패턴을 우선 사용합니다.

프롬프트에서 Momens 티켓 번호를 직접 알려준 경우에는 프롬프트 값을 우선합니다.

브랜치명과 프롬프트 어디에도 Momens 티켓 번호가 없으면 임의로 만들지 않습니다.

테스트 결과와 스크린샷 여부도 임의로 만들지 않습니다.

`project.pbxproj`, `Package.resolved` 변경은 원본 diff를 풀어 쓰지 않고 한 줄로 요약합니다.

## 주의할 점

- 이 에이전트들은 읽기 전용 탐색과 리뷰 목적입니다.
- 파일 수정이 필요하면 구현 작업을 별도로 요청해야 합니다.
- 리뷰 결과는 권장사항이므로, 실제 반영 여부는 변경 범위와 요구사항에 맞춰 판단합니다.
- iOS/SwiftUI 작업의 최신 기준은 `AGENTS.md`와 `.agents/.skills/momens-ios/`를 우선 확인합니다.
- 작업 관리, 브랜치, 커밋, PR 흐름의 최신 기준은 `AGENTS.md`와 `.agents/.skills/momens-workflow/`를 우선 확인합니다.
