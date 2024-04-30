### Before anything...
This is a Work In Progress, but mostly because I feel like this can still be improved, and haven't fully tested its use cases.

# TypeFamily
A Swift package, and a way to create groups of types so they can be addressed using compilation-time checks. It can be used to do type-erasure where you can always go back to the original type because you always know all the possible types its specific types. If a new type is added, the compiler will let you know if any `switch` is not handling this new child type. It does all of this through Swift Macros and a couple Protocols.

```swift
import TypeFamily

protocol ArtistGroup: TypeFamilyChild, Equatable {
    var memberCount: Int { get }
}

@TypeFamily(.keyPathed) @dynamicMemberLookup
enum MusicGroup: Equatable {
    typealias TypeChild = ArtistGroup
    
    @TypeFamilyChild
    struct Orchestra: TypeChild {
        let director: String
        let memberCount: Int
    }
    
    @TypeFamilyChild("popArtist")
    struct PopProducingTeam: TypeChild {
        let vocalist: String
        let presentedAsSolo: Bool
        let teamMembersCount: Int
        var memberCount: Int {
            presentedAsSolo ? 1 : teamMembersCount + 1
        }
    }
}

let presentations: [MusicGroup] = [
    .orchestra(.init(director: "A", memberCount: 20)),
    .popArtist(.init(vocalist: "B", presentedAsSolo: true, teamMembersCount: 20)),
]

for presentation in presentations {
    print("Members in main scenario: \(presentation.memberCount)")
    switch presentation {
    case .orchestra(let val):
        print("Everyone besides \(val.director) need to enter stage in advance")
    case .popArtist(let val):
        print("\(val.vocalist) needs help entering stage at the start of the show")
    }
    let value = presentation.childValue
    print(presentation == .wrapping(value)) // true
}
```

## How do I include in my project?

This is a Swift Package. Check your project's Package Dependencies in case you're using a Xcode Project/Workspace, or your `Package.swift` file if you're writing a Swift Package. Xcode will request you to enable Macro expansion for TypeAlias. This is what makes the compiler generate code, so enable it. Also, some versions of Xcode seem to need a restart (Close Xcode fully, open Xcode again) before picking up on macros.

## Using it
First, you declare the parent type. This will always be an `enum`, and have the macro `@TypeFamily` at the start of it.
```swift
@TypeFamily
enum ExampleParent {

}
```
The compiler will request from you to specifiy a type for the children to share between them, under the type alias `TypeChild`
```swift
protocol ExampleProtocol {
    var aMethodThatAllChilrenHave: Bool { get }
}
@TypeFamily
enum ExampleParent {
    typealias TypeChild = ExampleProtocol
}
```
Now you can add any child type you need. The child type will need to be declared inside the parent type, to inherit/conform to `TypeChild` and have the macro `@TypeFamilyChild`.
```swift
// ...
    @TypeFamilyChild
    struct ExampleChild: TypeChild {
        let aMethodThatAllChilrenHave: Bool
        let somethingOnlyThisChildHas: Int
    }
// ...
```
... and that's it!

## What the macros generate:
- An `enum` case for each type you add based on the name of the type. 
  ```swift
  case exampleChild(ExampleChild)
  ```
  If you want to customize the case name, you can add a String to the `@TypeFamilyChild` parameters
  ```swift
  @TypeFamilyChild("customEnumCaseName")
  // This generates `customEnumCaseName(ExampleChild)`
  ```
- A computed property for the enum that returns the object inside any case, type-erased to `any TypeChild`
  ```swift
  var childValue: any TypeChild
  // ...
  let exampleParent = ExampleParent.exampleChild(.init(/* ... */))
  print(exampleParent.childValue.aMethodThatAllChilrenHave)
  ```
  You can also specify the option `.keyPathed` to `@TypeFamily`, together with `@dynamicMemberLookup`, to be able to use child properties directly from its parent
  ```swift
  @TypeFamily(.keyPathed) @dynamicMemberLookup
  enum ExampleParent {
  // ...
  let exampleParent = ExampleParent.exampleChild(.init(/* ... */))
  print(exampleParent.aMethodThatAllChilrenHave)
  ```
- A method for the child object to be converted back to its parent type
  ```swift
  let exampleParent = ExampleParent.exampleChild(.init(/* ... */))
  let child = exampleParent.childValue
  let anotherParent = ExampleParent.wrapping(child) // Same as `exampleParent`
  ```
