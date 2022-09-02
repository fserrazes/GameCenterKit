//  Created on 02.09.22
//  Copyright © 2022 Flavio Serrazes. All rights reserved.

import SwiftUI

public struct PlayerEntry: Identifiable {
    public let id: String
    public let displayName: String
    let photo: Image?
    let leaderboard: Leaderboard
    
    struct Leaderboard {
        let rank: Int
        let score: Int
    }
}
