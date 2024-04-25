//
//  File.swift
//
//
//  Created by Jhonatan A. on 22/04/24.
//

import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct TypeFamilyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TypeFamilyChildMacro.self,
        TypeFamilyParentMacro.self,
    ]
}
