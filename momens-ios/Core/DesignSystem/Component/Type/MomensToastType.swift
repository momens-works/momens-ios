enum MomensToastType {
    case warning
    case checkbox(actionTitle: String, subtitle: String?, onTap: () -> Void)
}
