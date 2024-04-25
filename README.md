### Before anything...
This is a Work In Progress, but mostly because I feel like this can still be improved, and haven't fully tested its use cases.

# TypeFamily

A Swift package, and a way to create groups of types so they can be addressed using compilation-time checks. It does this through Swift Macros.

## Why?

Well, I wanted to have a bunch of types that conform to a protocol, and then make different checks for each of those types like things that are type-specific, but then I didn't want to accidentally miss a type between updates where I added a new type but forgot to add the type to every place where all types are used/checked. Well, the solution for me was to put all of them in an Enum. I found myself doing this a couple different times, but now that required quite a bit of code around it. So, I made this macro

## Example

```swift
import TypeFamily

protocol ArtistGroup: TypeFamilyChild {
    var memberCount: Int { get }
}

@TypeFamily
enum MusicGroup {
    typealias TypeChild = ArtistGroup
    
    @TypeFamilyChild
    struct Orchestra: TypeChild {
        let director: String
        let memberCount: Int
    }
    
    @TypeFamilyChild("popArtist")
    struct PopProducingTeam: TypeChild {
        let vocalist: String
        let publiclyPresentedAsSoloArtist: Bool
        let teamMembersCount: Int
        var memberCount: Int {
            publiclyPresentedAsSoloArtist ? 1 : teamMembersCount + 1
        }
    }
}

let presentations: [MusicGroup] = [
    .orchestra(.init(director: "A", memberCount: 20)),
    .popArtist(.init(vocalist: "B", publiclyPresentedAsSoloArtist: true, teamMembersCount: 20)),
]

for presentation in presentations {
    print("Members in main scenario: \(presentation.typeChild().memberCount)")
}

let popArtists: [MusicGroup.PopProducingTeam] = presentations.compactMap { $0.casted() }
for popArtist in popArtists {
    print("\(popArtist.vocalist) will need help entering stage")
}
```

## How do I include in my project?

This is a Swift Package. Check your project's Package Dependencies in case you're using a Xcode Project/Workspace, or your `Package.swift` file if you're writing a Swift Package
