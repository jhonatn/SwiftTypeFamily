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
