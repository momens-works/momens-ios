import SwiftUI

struct NavigationPlaceholderView: View {
    let title: String

    var body: some View {
        Color.clear
            .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        NavigationPlaceholderView(title: "시그널")
    }
}
