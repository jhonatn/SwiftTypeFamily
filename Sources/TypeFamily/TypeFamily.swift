import Foundation
import TypeFamilyCore

public typealias TypeFamilyParent = TypeFamilyCore.TypeFamilyParent
public typealias TypeFamilyChild = TypeFamilyCore.TypeFamilyChild

@attached(extension, names: arbitrary, conformances: TypeFamilyParent)
@attached(member, names: arbitrary)
public macro TypeFamily() = #externalMacro(
    module: "TypeFamilyMacros",
    type: "TypeFamilyParentMacro"
)

@attached(extension, names: arbitrary, conformances: TypeFamilyChild)
@attached(member, names: named(wrappedIntoParent))
public macro TypeFamilyChild(
    _ method: String
) = #externalMacro(
    module: "TypeFamilyMacros",
    type: "TypeFamilyChildMacro"
)

@attached(extension, names: arbitrary, conformances: TypeFamilyChild)
@attached(member, names: named(wrappedIntoParent))
public macro TypeFamilyChild(
) = #externalMacro(
    module: "TypeFamilyMacros",
    type: "TypeFamilyChildMacro"
)
