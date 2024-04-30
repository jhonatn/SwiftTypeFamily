//
//  File.swift
//  
//
//  Created by Jhonatan A. on 30/04/24.
//

import Foundation

public protocol TypeFamilyParent {
    associatedtype TypeChild//: TypeFamilyChild
    var childValue: Self.TypeChild { get }
}

public extension TypeFamilyParent {
    func casted<T>(`as` castingType: T.Type = T.self) -> T? {
        childValue as? T
    }
}
