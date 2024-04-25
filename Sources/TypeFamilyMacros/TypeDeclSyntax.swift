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

typealias TypeDeclSyntax = DeclGroupSyntax & NamedDeclSyntax

extension DeclSyntax {
    func asTypeDecl() -> TypeDeclSyntax? {
        if let childStructDecl = self.as(StructDeclSyntax.self) {
            return childStructDecl
        } else if let childClassDecl = self.as(ClassDeclSyntax.self) {
            return childClassDecl
        } else if let childEnumDecl = self.as(EnumDeclSyntax.self) {
            return childEnumDecl
        } else if let childActorDecl = self.as(ActorDeclSyntax.self) {
            return childActorDecl
        }
        return nil
    }
}

extension DeclGroupSyntax {
    func asTypeDecl() -> TypeDeclSyntax? {
        if let childStructDecl = self.as(StructDeclSyntax.self) {
            return childStructDecl
        } else if let childClassDecl = self.as(ClassDeclSyntax.self) {
            return childClassDecl
        } else if let childEnumDecl = self.as(EnumDeclSyntax.self) {
            return childEnumDecl
        } else if let childActorDecl = self.as(ActorDeclSyntax.self) {
            return childActorDecl
        }
        return nil
    }
}
