# GameCenterKit

<p>
    <img src="https://github.com/fserrazes/GameCenterKit/actions/workflows/CI.yml/badge.svg" />
    <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" />
    </a>
    <img src="https://img.shields.io/badge/iOS-14.0+-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
</p>

A Swift package for iOS that wraps GameKit with support for UIKit and SwiftUI.

Enable players to interact with friends, compare leaderboard ranks and earn achievements.

# Requirements

The latest version of GameKitUI requires:

    - Swift 5+
    - iOS 14+
    - Xcode 13+

# Installation

## Swift Package Manager

Add the following to your package dependencies:

```swift
.package(url: "https://github.com/fserrazes/GameCenterKit.git", branch: "main")

```

# Usage

## Requirements

    1. The local player must be authenticated on Game Center
    2. Your app must have a leaderboard identifier defined in **App Store Connect**.

## Authenticate Player

Authenticates the local player with Game Center (must be done before other actions).

### Completion-based API:
    
```swift
GameCenterKit.shared.authenticate { isAuthenticated in
if isAuthenticated {
    // Local player is authenticated
} else {
    // Local player is not authenticated
}
```

### Async/await API:

```swift
let state = await GameCenterKit.shared.authenticate()
```

## Present Game Center UI

There are 3 options:

    1. Toggle AccessPointView
    2. Present from a ViewController (UIKit)
    3. Present from a View (SwiftUI)

### Toggle AccessPointView

```swift
GameCenterKit.shared.toggleGameAccessPointView()
```

### UIKit Example

```swift
do {
    try GameCenterKit.shared.showGameCenter(viewController: self)
} catch {
    print(error)
}
```

### SwiftUI Example

```swift
import SwiftUI
import GameCenterKit

struct ContentView: View {
    @State var isGameCenterOpen: Bool = false
    
    var body: some View {
        VStack {
            Button("Open GameCenter View") {
                isGameCenterOpen = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .sheet(isPresented: $isGameCenterOpen) {
            GameCenterView()
        }
    }
}
```

## Leaderboards

Define your leaderboard identifier:

```swift
let identifierId: String = "your-app-leaderboard-id"
```

### Retrieve Score

The score earned by the local player (time scope defined is all time).

```swift
if let score = try await GameCenterKit.shared.retrieveScore(identifier: identifierId) {
    print("best score: \(String(describing: score))")
}
```

### Retrieve Rank

The rank earned by the local player (time scope defined is all time).

```swift
do {
    let (current, previous) = try await GameCenterKit.shared.retrieveRank(identifier: identifierId)
    print("current rank: \(String(describing: current))")
    print("previous rank: \(String(describing: previous))")
} catch {
    print(error)
}
```

### Retrieve Best Players

The best players list and the number of total players (time scope defined is all time).
 
 ```swift
let topPlayers = 10  // Number of top players (1–50)  

do {
    let (players, totalPlayers) = try await GameCenterKit.shared.retrieveBestPlayers(
        identifier: identifierId, 
        topPlayers: topPlayers
    )
    print("total players: \(String(describing: totalPlayers))")
    
    for player in players {
        print("player: \(player.displayName)\t score: \(player.leaderboard.score)")
    }
} catch {
    print(error)
}
```

### Submit Score
    
```swift
let score: Int = 10

do {
    try await GameCenterKit.shared.submitScore(score: score, identifier: identifierId)
} catch {
    print(error)
}
```
## Achievements

Define your achievement identifier:

```swift
let achievementId: String = "your-app-achievement-id"
```

### Submit Achievement

```swift
let percent = 10.0 // Progress value (0–100)

do {
    try await GameCenterKit.shared.submitAchievement(identifier: achievementId, percent: percent)
} catch {
    print(error)
}
```

### Reset Achievements

Resets the percentage completed for all of the player’s achievements.

```swift
do {
    try await GameCenterKit.shared.resetAchievements()
} catch {
    print(error)
}
```

## Documentation
+ [Apple Documentation GameKit](https://developer.apple.com/documentation/gamekit/)
