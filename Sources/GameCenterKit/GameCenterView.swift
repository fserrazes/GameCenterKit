//  Created on 02.09.22
//  Copyright © 2022 Flavio Serrazes. All rights reserved.

import SwiftUI
import GameKit

/// Presents the game center view provided by GameKit.
public struct GameCenterView: UIViewControllerRepresentable {
    let viewController: GKGameCenterViewController
    
    init(viewState: GKGameCenterViewControllerState = .default) {
        if #available(iOS 14.0, *) {
            self.viewController = GKGameCenterViewController(state: viewState)
        } else {
            let gameCenterViewController = GKGameCenterViewController()
            gameCenterViewController.viewState = viewState
            self.viewController = gameCenterViewController
        }
    }
    
    public func makeCoordinator() -> GameCenterCoordinator {
        return GameCenterCoordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let gameCenterViewController = viewController
        gameCenterViewController.gameCenterDelegate = context.coordinator
        return gameCenterViewController
    }
    
    public func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        return
    }
}

public class GameCenterCoordinator: NSObject, GKGameCenterControllerDelegate {
    let view: GameCenterView
    
    init(_ view: GameCenterView) {
        self.view = view
    }
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
