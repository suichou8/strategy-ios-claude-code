# Project Context for Claude Code

## Project Overview
**Project Name**: strategy-ios-claude-code
**Type**: iOS Application
**Platform**: iOS 15.0+
**Language**: Swift 5.9+
**UI Framework**: SwiftUI / UIKit (specify preference)

## Architecture & Design Patterns
- **Architecture**: MVVM / MVC / Clean Architecture / VIPER (choose one)
- **Dependency Management**: Swift Package Manager (SPM) / CocoaPods / Carthage
- **Design Patterns**:
  - Coordinator for navigation
  - Repository pattern for data layer
  - Dependency Injection

## Project Structure
```
strategy-ios-claude-code/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Core/
│   ├── Extensions/
│   ├── Utilities/
│   └── Constants/
├── Features/
│   ├── [FeatureName]/
│   │   ├── Models/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Services/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── LaunchScreen.storyboard
├── Network/
│   ├── APIClient.swift
│   ├── Endpoints/
│   └── Models/
├── Storage/
│   ├── CoreData/
│   ├── UserDefaults/
│   └── Keychain/
└── Tests/
    ├── UnitTests/
    └── UITests/
```

## Technical Stack
- **UI Framework**: SwiftUI / UIKit
- **Networking**: URLSession / Alamofire
- **Database**: Core Data / SQLite / Realm
- **Async Programming**: async/await, Combine
- **Image Loading**: Kingfisher / SDWebImage
- **Analytics**: Firebase Analytics / Mixpanel
- **Crash Reporting**: Crashlytics / Sentry
- **CI/CD**: Xcode Cloud / GitHub Actions / Fastlane

## Code Style & Conventions

### Swift Style Guide
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint with custom rules
- Line length: 120 characters
- Indentation: 4 spaces

### Naming Conventions
- **Classes/Structs**: PascalCase (e.g., `UserProfileViewController`)
- **Functions/Variables**: camelCase (e.g., `fetchUserData()`)
- **Constants**: camelCase with `k` prefix or UPPER_SNAKE_CASE
- **Protocols**: Suffix with `Protocol`, `Delegate`, or `DataSource`
- **Files**: Match the primary type name

### File Organization
- One type per file
- Extensions in separate files when complex
- Group related functionality using `// MARK: -` comments

## Development Workflow

### Branch Naming
- `feature/ticket-number-description`
- `bugfix/ticket-number-description`
- `hotfix/ticket-number-description`
- `release/version-number`

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: feat, fix, docs, style, refactor, test, chore

### Pull Request Template
- Description of changes
- Type of change (bug fix, feature, etc.)
- Testing performed
- Screenshots (for UI changes)
- Checklist:
  - [ ] Code follows style guidelines
  - [ ] Self-review completed
  - [ ] Tests added/updated
  - [ ] Documentation updated

## Build & Deployment

### Build Configurations
- **Debug**: Development environment
- **Staging**: Testing environment
- **Release**: Production environment

### Environment Variables
```swift
enum Environment {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development: return "https://dev-api.example.com"
        case .staging: return "https://staging-api.example.com"
        case .production: return "https://api.example.com"
        }
    }
}
```

### Code Signing
- Automatic signing for development
- Manual signing for distribution
- Certificates stored in CI/CD keychain

## Testing Strategy

### Unit Tests
- Minimum 70% code coverage
- Test all ViewModels and business logic
- Mock network calls and external dependencies

### UI Tests
- Test critical user flows
- Screenshot tests for key screens
- Accessibility testing

### Test Naming Convention
```swift
func test_methodName_condition_expectedResult() {
    // Test implementation
}
```

## Performance Guidelines
- App launch time < 400ms
- Frame rate: 60 FPS minimum
- Memory usage monitoring
- Network request optimization
- Image caching and lazy loading

## Security Requirements
- Keychain for sensitive data
- SSL pinning for API calls
- Obfuscation for sensitive strings
- No hardcoded credentials
- Biometric authentication where appropriate

## Accessibility
- VoiceOver support
- Dynamic Type support
- Minimum contrast ratios (WCAG AA)
- Semantic labels for all UI elements

## Commands & Scripts

### Common Commands
```bash
# Run tests
xcodebuild test -scheme strategy-ios-claude-code -destination 'platform=iOS Simulator,name=iPhone 15'

# Build for release
xcodebuild archive -scheme strategy-ios-claude-code -archivePath ./build/Release.xcarchive

# Run SwiftLint
swiftlint

# Format code
swift-format -i -r Sources/

# Generate documentation
swift doc generate Sources/ --module-name StrategyiOS -o ./docs
```

### Fastlane Lanes (if using Fastlane)
```bash
fastlane ios test        # Run all tests
fastlane ios beta        # Deploy to TestFlight
fastlane ios release     # Deploy to App Store
fastlane ios screenshots # Generate screenshots
```

## Dependencies
```swift
// Package.swift or Podfile content
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    // Add more as needed
]
```

## App Store Information
- **Bundle ID**: com.yourcompany.strategy-ios
- **App Store Connect Team ID**: [YOUR_TEAM_ID]
- **App Category**: [Category]
- **Minimum iOS Version**: 15.0
- **Supported Devices**: iPhone, iPad

## Documentation
- Code documentation using Swift DocC
- README.md for setup instructions
- CHANGELOG.md for version history
- API documentation in `/docs`

## Notes for Claude
- Always check existing code style before making changes
- Run tests before committing
- Update documentation when adding new features
- Follow the established project structure
- Consider performance and security implications
- Ensure accessibility compliance
- Test on multiple device sizes

## Project-Specific Rules
<!-- Add any project-specific rules or requirements here -->
-
-
-

---
*Last Updated: [Date]*
*Version: 1.0.0*