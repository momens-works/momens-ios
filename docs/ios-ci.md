# iOS CI

## 목적

`develop` 브랜치에 대한 Pull Request와 `develop` 브랜치의 push에서 SwiftLint, iOS Simulator 빌드, XCTest를 실행합니다. 워크플로는 `.github/workflows/ios-ci.yml`에 있습니다.

## 실행 조건

- `develop` 브랜치 push
- `develop`을 대상으로 하는 Pull Request 생성 또는 업데이트
- GitHub Actions의 **iOS CI** 수동 실행

같은 PR 또는 브랜치에서 새 실행이 시작되면, 이전에 실행 중인 iOS CI는 취소됩니다.

## 로컬 실행

프로젝트는 공유 Scheme `momens-ios`를 사용합니다. 아래 명령은 프로젝트 루트에서 실행합니다.

```bash
swiftlint lint --strict --config .swiftlint.yml
```

```bash
xcodebuild \
  -project momens-ios.xcodeproj \
  -scheme momens-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  CODE_SIGNING_ALLOWED=NO \
  build-for-testing
```

```bash
xcodebuild \
  -project momens-ios.xcodeproj \
  -scheme momens-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  CODE_SIGNING_ALLOWED=NO \
  test
```

SwiftLint은 Homebrew로 설치할 수 있습니다.

```bash
brew install swiftlint
```

## CI 구성

- GitHub-hosted `macos-26` runner에서 Xcode 26.5를 선택합니다.
- Swift Package Manager의 `SourcePackages`를 `Package.resolved` 해시로 캐시합니다.
- simulator 빌드와 테스트에서는 `CODE_SIGNING_ALLOWED=NO`를 사용하므로 CI용 서명 인증서나 프로비저닝 프로파일이 필요하지 않습니다.
- 현재 `Config/Secrets.xcconfig`와 `GoogleService-Info.plist`는 Git 추적 대상이 아니며, 이 CI 구성은 이를 읽지 않습니다. 이후 빌드가 비밀 설정을 요구하게 되면 값을 저장소에 추가하지 말고 GitHub Actions Secrets 또는 Variables에서 파일을 생성하도록 별도 구성합니다.

## 실패 확인

Pull Request의 **Checks** 탭 또는 Actions 실행 화면에서 실패한 단계와 `xcodebuild` 로그를 확인합니다. SwiftLint 위반은 경고를 포함해 실패로 처리합니다. 각 실행은 `xctest-results` 아티팩트로 XCTest 결과 번들도 보관합니다.

## GitHub 저장소에서 추가할 설정

CI가 기본 브랜치에서 한 번 성공한 뒤, GitHub의 **Settings → Branches → develop 브랜치 보호 규칙**에서 다음을 수동으로 설정합니다.

1. Pull Request 승인 또는 최신 브랜치 요구 정책을 팀 기준에 맞게 선택합니다.
2. **Require status checks to pass before merging**를 활성화합니다.
3. `SwiftLint, Build, and XCTest` 상태 검사를 필수로 지정합니다.

이 저장소 설정은 워크플로만으로 변경하지 않습니다.
