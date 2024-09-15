//
//  MacroDefinitions.swift
//
//
//  Created by Balázs Erdész on 15/09/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DeviceDependentMacro.self
    ]
}
