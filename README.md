# GameCenterKit

[![Swift 5](https://img.shields.io/badge/language-Swift-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/OS-macOS-green.svg)](https://developer.apple.com/macos/)
[![iOS](https://img.shields.io/badge/OS-iOS-green.svg)](https://developer.apple.com/ios/)

This is a Swift package with support for iOS that allows to use GameKit with UIKit and SwiftUI.

Enable players to interact with friends, compare leaderboard ranks, earn achievements.

# Requirements

The latest version of GameKitUI requires:

    * Swift 5+
    * iOS 14+
    * Xcode 13+

# Installation

## Swift Package Manager

Using SPM add the following to your dependencies

'GameCenterKit', 'main', 'https://github.com/fserrazes/GameCenterKit.git'


# How to use? 

## Requirements

    1. The local user must be authenticated on Game Center
    2. Your app need an identifier leaderboard defined in App Store Connect.

## First the local user must be authenticated on Game Center.

```swift
GameCenterKit.shared.authenticate()
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

## Leaderboard actions

### Retrieve Score

```swift
let identifier: String = "your-app-leaderboard-id"
let bestScore: Int = 0

if let score = try await GameCenterKit.shared.retrieveScore(identifier: identifier) {
    print("best score: \(String(describing: score))")
    self.bestScore = score
}
```

### Submit Score

```swift
let identifier: String = "your-app-leaderboard-id"
let score: Int = 10

do {
    try await GameCenterKit.shared.submitScore(score: score, identifier: identifier)
} catch {
    print(error)
}
```



