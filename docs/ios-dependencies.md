# iOS Dependencies

`MOM-1036`에서 Android 앱의 기능 기반 의존성을 iOS에 맞게 정리했습니다.
모든 외부 라이브러리는 Swift Package Manager로 관리하며, 패키지의 다음 메이저 버전 전까지의 최신 패치/마이너 버전을 허용합니다.

| 영역 | iOS 구성 | Android 대응 |
| --- | --- | --- |
| 네트워크 | Alamofire | OkHttp, Retrofit |
| 이미지 로딩·캐시 | Kingfisher | Coil |
| Lottie 애니메이션 | Lottie | lottie-compose |
| FCM·설치 식별자 | FirebaseMessaging, FirebaseInstallations | firebase-messaging, firebase-installations |
| Google 로그인 | GoogleSignIn, GoogleSignInSwift | Credentials, Google ID |
| 로컬 SQLite | GRDB | Room |
| 로깅 | Apple `OSLog` | Timber |
| 설정·보안 저장소 | `UserDefaults`, Keychain | DataStore Preferences |
| 비동기 | Swift Concurrency | Kotlin Coroutines |
| 의존성 조립 | `DIContainer` 생성자 주입 | Hilt |
| 화면 이동 | SwiftUI `NavigationStack` | Navigation Compose |
| 백그라운드 작업 | `BackgroundTasks` | WorkManager |

## Integration notes

- Firebase를 사용하려면 Firebase Console에서 내려받은 `GoogleService-Info.plist`를 앱 타깃에 추가해야 합니다. 이 파일은 비밀값으로 취급하며 저장소에 커밋하지 않습니다.
- FCM을 사용하려면 Push Notifications capability와 APNs 인증 키를 별도로 설정해야 합니다.
- Google 로그인에는 iOS OAuth client ID와 URL scheme 설정이 필요합니다.
- SQLite가 실제 기능에 필요해질 때 `Data/{Feature}/Local`에 GRDB 기반 data source를 추가합니다. 단순 설정과 민감한 값은 SQLite가 아닌 `UserDefaults`와 Keychain을 사용합니다.
