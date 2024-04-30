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
import TypeFamilyCore

public struct TypeFamilyParentMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let caseBundles = try caseBundles(for: declaration)
        let options: Set<TypeFamilyParentOptions> = {
            let arguments = node.arguments?.as(LabeledExprListSyntax.self).map(Array<LabeledExprSyntax>.init)
            guard let arguments else {
                return .init()
            }
            let result = arguments
                .compactMap { $0.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text }
                .compactMap(TypeFamilyParentOptions.init(rawValue:))
            return Set(result)
        }()
        
        return [
            "public typealias TypeParent = Self",
        ]
        +
        caseBundles.map { "case \($0.name)(\($0.type))" }
        +
        [
            """
            public var childValue: any Self.TypeChild {
                switch self {
                \(raw: caseBundles
                    .map { "case .\($0.name)(let child): return child" }
                    .joined(separator: "\n")
                )
                }
            }
            """,
        ]
        +
        [
            !options.contains(.keyPathed) ? nil : """
            public subscript<T>(dynamicMember keyPath: KeyPath<any Self.TypeChild, T>) -> T {
                childValue[keyPath: keyPath]
            }
            """
        ].compactMap{$0}
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
