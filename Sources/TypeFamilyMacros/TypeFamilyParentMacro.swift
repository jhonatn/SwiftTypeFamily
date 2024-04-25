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

public struct TypeFamilyParentMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let caseBundles = try caseBundles(for: declaration)
        
        return [
            "typealias TypeParent = Self",
        ]
        +
        caseBundles.map { "case \($0.name)(\($0.type))" }
        +
        [
            """
            func typeChild() -> any Self.TypeChild {
                switch self {
                \(raw: caseBundles
                    .map { "case .\($0.name)(let child): return child" }
                    .joined(separator: "\n")
                )
                }
            }
            """,
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclSyntaxProtocol,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        return [
            simpleConformanceBlock(
                of: type,
                conformingTo: "TypeFamily.TypeFamilyParent"
            ),
        ]
    }
    
    typealias CaseBundle = (name: TokenSyntax, type: TokenSyntax)
    static func caseBundles(for declaration: some SyntaxProtocol) throws -> [CaseBundle] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw TypeFamilyError(message: "Not enum")
        }
        
        let decls: [any TypeDeclSyntax] = enumDecl.memberBlock.members.compactMap {
            $0.decl.asTypeDecl()
        }
        
        typealias CaseBundle = (name: TokenSyntax, type: TokenSyntax)
        let caseBundles: [CaseBundle] = decls
            .compactMap { decl -> CaseBundle? in
                let attribute = decl.attributes
                    .compactMap {
                        $0.as(AttributeSyntax.self)
                    }
                    .first(where: {
                        $0.attributeName
                            .as(IdentifierTypeSyntax.self)?.name.text
                            .hasSuffix("TypeFamilyChild") ?? false
                    })
                guard let attribute else {
                    return nil
                }
                let stringArgument = attribute
                    .arguments?.as(LabeledExprListSyntax.self)?
                    .first?.expression.as(StringLiteralExprSyntax.self)?
                    .segments.first?.as(StringSegmentSyntax.self)?
                    .content ??  {
                        let defaultEnumName = decl.name.text.enumCase()
                        return TokenSyntax.identifier(defaultEnumName)
                    }()
                return (stringArgument, decl.name)
            }
        return caseBundles
    }
}
