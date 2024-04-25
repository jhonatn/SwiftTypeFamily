import Foundation

public protocol TypeFamilyParent {
    associatedtype TypeChild//: TypeFamilyChild
    func typeChild() -> Self.TypeChild
}

public protocol TypeFamilyChild {
    associatedtype TypeParent: TypeFamilyParent
    func wrappedIntoParent() -> TypeParent
}

public extension TypeFamilyParent {
    func casted<T>(`as` castingType: T.Type = T.self) -> T? {
        typeChild() as? T
    }
}

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
