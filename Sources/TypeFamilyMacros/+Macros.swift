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
import SwiftDiagnostics

struct TypeFamilyError: Swift.Error, CustomStringConvertible {
    let message: String
    
    var description: String {
        message
    }
}

func simpleConformanceBlock<TSP: TypeSyntaxProtocol>(
    of type: TSP,
    conformingTo conformanceTokenSyntax: TokenSyntax...,
    where genericWhereClause: GenericWhereClauseSyntax? = nil,
    memberBlock: MemberBlockSyntax = ""
) -> ExtensionDeclSyntax {
    ExtensionDeclSyntax(
        extensionKeyword: "extension",
        extendedType: type,
        inheritanceClause: conformanceTokenSyntax.isEmpty ? nil : .init(
            inheritedTypes: .init(
                conformanceTokenSyntax.map {
                    InheritedTypeSyntax(
                        type: IdentifierTypeSyntax(name: $0)
                    )
                }
            )
        ),
        genericWhereClause: genericWhereClause,
        memberBlock: "{\(memberBlock)}"
    )
}

extension String {
    @inlinable
    func enumCase() -> String {
        guard !isEmpty else {
            return self
        }
        var result = self
        let firstLetter = result.removeFirst()
        return firstLetter.lowercased() + result
    }
}
