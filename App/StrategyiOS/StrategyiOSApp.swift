import SwiftUI
import AppFeature
import StockKit

@main
struct StrategyiOSApp: App {
    @State private var stockService = StockService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stockService)
        }
    }
}
