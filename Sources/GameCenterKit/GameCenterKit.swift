import SwiftUI
import GameKit
import OSLog

public enum GameCenterError: Error {
    case notAuthenticated
    case emptyLeaderboad(String)
    case failure(Error)
}

public class GameCenterKit: NSObject, GKLocalPlayerListener {
    private let looger = Logger(subsystem: "com.serrazes.gamecenterkit", category: "GameCenter")
    private (set) var localPlayer = GKLocalPlayer.local
    private var isAuthenticated: Bool {
        return localPlayer.isAuthenticated
    }

    // Create as a Singleton to avoid more than one instance.
    public static var shared: GameCenterKit = GameCenterKit()
    
    private override init() {
        super.init()
    }
    
    /// Authenticates the local player with in Game Center if it's possible.
    ///
    /// If viewController is nil, Game Center authenticates the player and the player can start your game.
    /// Otherwise, present the view controller so the player can perform any additional actions to complete authentication.
    /// - Returns: Player autentication status.
    public func authenticate() async -> Bool {
        return await withCheckedContinuation { continuation in
            localPlayer.authenticateHandler = { [self] (viewController, error) in
                guard error == nil else {
                    looger.error("Error on user authentication: \(error)")
                    continuation.resume(returning: false)
                    return
                }
                
                GKAccessPoint.shared.isActive = false
                
                if self.localPlayer.isAuthenticated {
                    localPlayer.register(self)
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    // MARK: - Leaderboad methods

    /// The score earned by the local player (time scope defined is all time).
    /// - Requires: The local user must be authenticated on Game Center.
    /// - Throws: GameCenterError.notAuthenticated: if local player is not authenticated.
    ///           GameCenterError.failure: If an error occurred, It holds an error that describes the problem.
    /// - Parameter identifier: leaderboard id defined in App Store Connect.
    /// - Returns: Player score's, if a previous score was submitted.
    public func retrieveScore(identifier: String) async throws -> Int? {
        guard isAuthenticated else { throw GameCenterError.notAuthenticated }

        do {
            let leaderboards: [GKLeaderboard] = try await GKLeaderboard.loadLeaderboards(IDs: [identifier])
            if leaderboards.isEmpty {
                looger.warning("Leaderboad with \(identifier) is empty")
                throw GameCenterError.emptyLeaderboad(identifier)
            }
            let (localPlayerEntry, _) = try await leaderboards[0].loadEntries(for: [localPlayer], timeScope: .allTime)
            return localPlayerEntry?.score
        } catch {
            looger.error("Error to retrieve leaderboad \(identifier) score: \(error)")
            throw GameCenterError.failure(error)
        }
    }

    /// The rank earned by the local player (time scope defined is all time).
    ///
    /// The current and previous rankings are returned to measure the evolution of the player.
    /// - Requires: The local user must be authenticated on Game Center.
    /// - Throws: GameCenterError.notAuthenticated: if local player is not authenticated.
    ///           GameCenterError.failure: If an error occurred, It holds an error that describes the problem.
    /// - Parameter identifier: leaderboard id defined in App Store Connect.
    /// - Returns: Current and previous player rank's, if any score was submitted.
    public func retrieveRank(identifier: String) async throws -> (current: Int?, previous: Int?) {
        guard isAuthenticated else { throw GameCenterError.notAuthenticated }

        var currentRank: Int? = nil
        var previousRank: Int? = nil

        do {
            let leaderboards: [GKLeaderboard] = try await GKLeaderboard.loadLeaderboards(IDs: [identifier])
            if leaderboards.isEmpty {
                looger.warning("Leaderboad with \(identifier) is empty")
                throw GameCenterError.emptyLeaderboad(identifier)
            }
            if let (currentEntry, _) = try? await leaderboards[0].loadEntries(for: [localPlayer], timeScope: .allTime) {
                currentRank = currentEntry?.rank
            }
            if let (previousEntry, _) = try? await leaderboards[0].loadPreviousOccurrence()?.loadEntries(for: [localPlayer], timeScope: .allTime) {
                previousRank = previousEntry?.rank
            }
        } catch {
            looger.error("Error to retrieve leadeboard \(identifier) rank: \(error)")
            throw GameCenterError.failure(error)
        }
        return (currentRank, previousRank)
    }

    /// The best players list and the number of total players (time scope defined is all time).
    /// - Requires: The local user must be authenticated on Game Center.
    /// - Throws: GameCenterError.notAuthenticated: if local player is not authenticated.
    ///           GameCenterError.failure: If an error occurred, It holds an error that describes the problem.
    /// - Parameters:
    ///   - identifier: leaderboard id defined in App Store Connect.
    ///   - topPlayers: Specifies the number of top players (1 - 50) to use for getting the scores.
    /// - Returns: Ordered top player list and the number of total players.
    public func retrieveBestPlayers(identifier: String, topPlayers: Int = 5) async throws -> (player: [PlayerEntry], totalPlayers: Int) {
        guard isAuthenticated else { throw GameCenterError.notAuthenticated }

        let maxTopPlayers = topPlayers > 50 ? 50 : topPlayers
        let range = NSRange(1...maxTopPlayers)

        var players = [PlayerEntry]()

        do {
            let leaderboards: [GKLeaderboard] = try await GKLeaderboard.loadLeaderboards(IDs: [identifier])
            if leaderboards.isEmpty {
                looger.warning("Leaderboad with \(identifier) is empty")
                throw GameCenterError.emptyLeaderboad(identifier)
            }
            let (_ , entries, totalPlayerCount) = try await leaderboards[0].loadEntries(for: .global, timeScope: .allTime, range: range)
            entries.forEach { entry in
                var image: Image?
                entry.player.loadPhoto(for: .small) { photo, error in
                    image = Image(uiImage: photo ?? UIImage())
                }
                players.append(PlayerEntry(id: entry.player.gamePlayerID, displayName: entry.player.displayName, photo: image,
                                      leaderboard: PlayerEntry.Leaderboard(rank: entry.rank, score: entry.score)))
            }
            return (players.sorted(by: { $0.leaderboard.score < $1.leaderboard.score }), totalPlayerCount)

        } catch {
            looger.error("Error to retrieve leaderboad \(identifier) best players: \(error)")
            throw GameCenterError.failure(error)
        }
    }

    /// Reports a high score eligible for placement on a leaderboard.
    /// - Requires: The local user must be authenticated on Game Center.
    /// - Throws: GameCenterError.notAuthenticated: if local player is not authenticated.
    ///           GameCenterError.failure: If an error occurred, It holds an error that describes the problem.
    /// - Parameters:
    ///   - score: The score earned by the local player
    ///   - identifier: leaderboard id defined in App Store Connect.
    public func submitScore(score: Int, identifier: String) async throws {
        guard isAuthenticated else { throw GameCenterError.notAuthenticated }

        do {
            try await GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: [identifier])
        } catch {
            looger.error("Error to submit leaderboard \(identifier) scores: \(error)")
            throw GameCenterError.failure(error)
        }
    }

    // MARK: - Achievement methods

    /// Reports progress on an achievement, if it has not been completed already.
    /// - Requires: The local user must be authenticated on Game Center.
    /// - Throws: GameCenterError.notAuthenticated: if local player is not authenticated.
    ///           GameCenterError.failure: If an error occurred, It holds an error that describes the problem.
    /// - Parameters:
    ///   - identifier: achievement id defined in App Store Connect.
    ///   - percent: A percentage value (0 - 100) stating how far the user has progressed on the achievement
    ///   - banner: Define if achievement banner is shown with the local player progress.
    public func submitAchievement(identifier: String, percent: Double, showsCompletionBanner banner: Bool = true) async throws {
        guard isAuthenticated else { throw GameCenterError.notAuthenticated }

        do {
            let achievements = try await GKAchievement.loadAchievements()

            // Find an existing achievement, otherwise, create a new achievement.
            // If the achievement isn’t in the array, your game hasn’t reported any progress for this player yet, and the dashboard shows it in the locked state.
            var achievement = achievements.first(where: {$0.identifier ==  identifier})
            if  achievement == nil {
                achievement = GKAchievement(identifier: identifier)
            }

            if let achievement = achievement, !achievement.isCompleted && achievement.percentComplete < percent {
                achievement.percentComplete = min(percent, 100)
                achievement.showsCompletionBanner = banner

                // Report the Player’s Progress
                try await GKAchievement.report([achievement])
            }
        } catch {
            looger.error("Error to submit achievement \(identifier) progress: \(error)")
            throw GameCenterError.failure(error)
        }
    }

    /// Resets the percentage completed for all of the player’s achievements.
    /// - Requires: The local user must be authenticated on Game Center.
    /// - Throws: GameCenterError.notAuthenticated: if local player is not authenticated.
    ///           GameCenterError.failure: If an error occurred, It holds an error that describes the problem.
    public func resetAchievements() async throws {
        guard isAuthenticated else { throw GameCenterError.notAuthenticated }

        do {
            try await GKAchievement.resetAchievements()
        } catch {
            looger.error("Error to reset achievements: \(error)")
            throw GameCenterError.failure(error)
        }
    }
}

extension GameCenterKit: GKGameCenterControllerDelegate {
    public func toogleGameAccessPointView() {
        if isAuthenticated {
            GKAccessPoint.shared.isActive.toggle()
        }
    }

    /// Presents the game center view controller provided by GameKit.
    ///
    /// For SwiftUI projects consider using GameCenterView instead.
    /// - Requires: The local user must be authenticated on Game Center.
    /// - Throws: GameCenterError.notAuthenticated: if local player is not authenticated.
    /// - Parameters:
    ///   - viewController: The view controller to present GameKit's view controller from.
    ///   - viewState: The state in which to present the new view controller
    public func showGameCenter(viewController: UIViewController, viewState: GKGameCenterViewControllerState = .default) throws {
        guard isAuthenticated else { throw GameCenterError.notAuthenticated }
        
        let gameCenterViewController = GKGameCenterViewController(state: viewState)
        gameCenterViewController.gameCenterDelegate = self
        viewController.present(gameCenterViewController, animated: true)
    }

    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
