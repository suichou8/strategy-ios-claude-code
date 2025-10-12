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
    // 因为它们使用了 @Observable 宏（来自 NetworkKit）
    @State private var authManager = AuthManager.shared
    @State private var apiClient = APIClient.shared

    var body: some Scene {
        WindowGroup {
            ContentView(
                authManager: authManager,
                apiClient: apiClient
            )
        }
    }
}
