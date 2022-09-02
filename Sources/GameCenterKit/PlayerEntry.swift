//  Created on 02.09.22
//  Copyright © 2022 Flavio Serrazes. All rights reserved.

import SwiftUI

public struct PlayerEntry: Identifiable {
    public let id: String
    public let displayName: String
    public let photo: Image?
    public let leaderboard: Leaderboard
    
    public struct Leaderboard {
        public let rank: Int
        public let score: Int
    }
}
