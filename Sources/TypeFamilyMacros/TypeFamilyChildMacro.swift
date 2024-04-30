//
//  File.swift
//
//
//  Created by Jhonatan A. on 24/04/24.
//

import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TypeFamilyChildMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        return [
            simpleConformanceBlock(
                of: type,
                conformingTo: "TypeFamilyChild"
            ),
        ]
    }
    
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let typeDecl = declaration.asTypeDecl() else {
            return []
        }
        let arguments = node.arguments?.as(LabeledExprListSyntax.self)
        guard arguments?.count ?? 0 <= 1 else {
            throw TypeFamilyError(message: "Wrong syntax")
        }
        let methodArgument = arguments?.first?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.as(StringSegmentSyntax.self)?
            .content ?? {
                let defaultEnumName = typeDecl.name.text.enumCase()
                return TokenSyntax.identifier(defaultEnumName)
            }()
        return [
        ]
    }
}
