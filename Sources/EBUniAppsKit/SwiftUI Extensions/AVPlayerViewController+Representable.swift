//
//  AVPlayerViewController+Representable.swift
//  
//
//  Created by Balázs Erdész on 2023. 08. 13..
//

import Foundation
import AVKit
import SwiftUI

public extension AVPlayerViewController {
    /// A SwiftUI wrapper for `AVKit.AVPlayerViewController`.
    ///
    /// `SwiftUI.VideoPlayer` has no "Full Screen" control on its UI and provides no programmatic way to trigger full screen either as of now. This is why this wrap is necessary.
    struct Representable: UIViewControllerRepresentable {
        public let player: AVPlayer
        
        public init(player: AVPlayer) {
            self.player = player
        }
        
        public func makeUIViewController(context: Context) -> AVPlayerViewController {
            let controller = AVPlayerViewController()
            controller.player = player
            controller.entersFullScreenWhenPlaybackBegins = true
            controller.exitsFullScreenWhenPlaybackEnds = true
            
            return controller
        }
        
        public func updateUIViewController(_ uiViewController: AVPlayerViewController,
                                           context: Context) {
            // no-op
        }
    }
}
