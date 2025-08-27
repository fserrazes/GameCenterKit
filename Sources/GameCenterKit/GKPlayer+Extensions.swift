//  Created on 27/08/2025
//  Copyright © 2025 Flavio Serrazes. All rights reserved.

import GameKit

extension GKPlayer {
    func loadPhoto(for size: GKPlayer.PhotoSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            self.loadPhoto(for: size) { photo, _ in
                continuation.resume(returning: photo)
            }
        }
    }
}
