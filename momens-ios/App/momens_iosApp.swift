//
//  momens_iosApp.swift
//  momens-ios
//
//  Created by seung on 9/10/26.
//

import SwiftUI

@main
struct MomensIOSApp: App {
    @State private var appCoordinator = AppCoordinator()
    @State private var container = DIContainer()

    init() {
        MomensTypography.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
                .environment(appCoordinator)
        }
    }
}
