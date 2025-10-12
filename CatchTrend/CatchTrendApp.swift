//
//  CatchTrendApp.swift
//  CatchTrend
//
//  Created by shuai zhang on 2025/10/12.
//

import SwiftUI
import CatchTrendPackage

@main
struct CatchTrendApp: App {
    // 使用 @State 包装 AuthManager 和 APIClient
    // AuthManager 使用 @Observable 宏，APIClient 是 actor
    @State private var authManager = AuthManager.shared
    @State private var apiClient = APIClient(authManager: AuthManager.shared)

    var body: some Scene {
        WindowGroup {
            ContentView(
                authManager: authManager,
                apiClient: apiClient
            )
        }
    }
}
