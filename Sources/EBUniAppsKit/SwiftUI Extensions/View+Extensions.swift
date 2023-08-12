//
//  View+Extensions.swift
//  
//
//  Created by Balázs Erdész on 2023. 08. 12..
//

import Foundation
import SwiftUI

extension View {
    /// Modifies the view with a symmetric scale effect where `size` is the scale for both height and width.
    func scaleEffect(of size: CGFloat) -> some View {
        self.scaleEffect(CGSize(width: size, height: size))
    }
}
