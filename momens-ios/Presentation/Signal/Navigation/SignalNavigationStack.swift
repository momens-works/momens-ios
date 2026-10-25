import SwiftUI

struct SignalNavigationStack: View {
    let container: DIContainer

    var body: some View {
        NavigationStack {
            NavigationPlaceholderView(title: "시그널")
        }
    }
}
