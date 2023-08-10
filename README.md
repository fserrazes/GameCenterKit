# GameCenterKit

<p>
    <img src="https://github.com/fserrazes/GameCenterKit/actions/workflows/CI.yml/badge.svg" />
    <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" />
    </a>
    <img src="https://img.shields.io/badge/iOS-14.0+-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
</p>

This is a Swift package with support for iOS that allows to use GameKit with UIKit and SwiftUI.

Enable players to interact with friends, compare leaderboard ranks and earn achievements.

# Requirements

The latest version of GameKitUI requires:

    - Swift 5+
    - iOS 14+
    - Xcode 13+

# Installation

## Swift Package Manager

Using SPM add the following to your dependencies

'GameCenterKit', 'main', 'https://github.com/fserrazes/GameCenterKit.git'

# How to use? 

## Requirements

    1. The local player must be authenticated on Game Center
    2. Your app need an identifier leaderboard defined in App Store Connect.

## First the local player must be authenticated on Game Center.

Authenticates the local player with in Game Center if it's possible.
    
```swift
do {
    let isAuthenticated = try await GameCenterKit.shared.authenticate()
    if isAuthenticated {
        // Local player is authenticated
    } else {
        // Local player is not authenticated
    }
} catch {
    // Handle any errors that might occur during authentication
}
```

## To presents the Game Center view provided by GameKit there are 3 options:

    1. Toggle AccessPointView
    2. Open from a ViewController (UIKit)
    3. Open from a View (SwiftUI)


### Toggle AccessPointView

```swift
GameCenterKit.shared.toogleGameAccessPointView()
```

### Open from a ViewController (UIKit)

```swift
do {
    try GameCenterKit.shared.showGameCenter(viewController: self)
} catch {
    print(error)
}
```

### Open from a View (SwiftUI)

```swift
import SwiftUI
import GameCenterKit

struct ContentView: View {
    @State var isGameCenterOpen: Bool = false
    
    var body: some View {
        VStack {
            Button {
                isGameCenterOpen = true
            } label: {
                Text("Open GameCenter View")
                    .padding(.all, 5.0)
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $isGameCenterOpen) {
            GameCenterView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

## Leaderboards actions

```swift
let identifierId: String = "your-app-leaderboard-id"
```

### Retrieve Score

The score earned by the local player (time scope defined is all time).

```swift
let bestScore: Int = 0

if let score = try await GameCenterKit.shared.retrieveScore(identifier: identifierId) {
    print("best score: \(String(describing: score))")
    self.bestScore = score
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
// Number of top players (1 - 50) to use for getting the scores.
let topPlayers: Int = 10     

do {
    let (players, totalPlayers) = try await GameCenterKit.shared.retrieveBestPlayers(identifier: identifierId, topPlayers: topPlayers)
    print("total players: \(String(describing: totalPlayers))")
    
    for player in players {
        print("player: \(player.displayName)\t score: \(player.leaderboard.score)")
    }
} catch {
    print(error)
}
```

### Submit Score

Report a high score eligible for placement on a leaderboard.
    
```swift
// The score earned by the local player
let score: Int = 10

do {
    try await GameCenterKit.shared.submitScore(score: score, identifier: identifierId)
} catch {
    print(error)
}
```
## Achievements actions

```swift
let achievementId: String = "your-app-achievement-id"
```

### Submit Achievement

Reports progress on an achievement, if it has not been completed already.

```swift
// A percentage value (0 - 100) stating how far the user has progressed on the achievement
let percent: Double = 10.0

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
