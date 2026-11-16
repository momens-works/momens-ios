enum SignalAccordionType: CaseIterable {
    case slack
    case github
    case figma
    case file

    var text: String {
        switch self {
        case .slack: "슬랙"
        case .github: "깃헙"
        case .figma: "피그마"
        case .file: "파일"
        }
    }

    var iconAssetName: String {
        switch self {
        case .slack: "ic_slack"
        case .github: "ic_github"
        case .figma: "ic_figma"
        case .file: "ic_file"
        }
    }
}
