//
//  File.swift
//  
//
//  Created by Jhonatan A. on 30/04/24.
//

import Foundation

public enum TypeFamilyParentOptions: String, Hashable {
    /// Inserts keypath subscripting code, so the TypeFamilyParent instance can access properties from its child.
    /// Note: This only adds a helper method to the class, but still requires having @dynamicMemberLookup added to the class. Also, because of a Swift limitation, this only lets you access properties. If you need access to functions, you'll have to call it from `childValue` instead
    case keyPathed
}
