//
//  DeviceOrientationModifier.swift
//
//
//  Created by Balázs Erdész on 16/09/2024.
//

#if os(iOS)
import Foundation
import SwiftUI
import UIKit

struct DeviceOrientationModifier: ViewModifier {
    @Binding var orientation: UIDeviceOrientation
    
    @MainActor
    private var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { _ in
                orientation = UIDevice.current.orientation
            }
    }
}

extension View {
    func bindOrientation(_ binding: Binding<UIDeviceOrientation>) -> some View {
        self.modifier(DeviceOrientationModifier(orientation: binding))
    }
}
#endif
