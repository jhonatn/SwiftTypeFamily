import TypeFamily

protocol ArtistGroup: TypeFamilyChild {
    var memberCount: Int { get }
}

@TypeFamily(.keyPathed) @dynamicMemberLookup
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
    print("Members in main scenario: \(presentation.memberCount)")
    switch presentation {
    case .orchestra(let value):
        print("All members besides \(value.director) will need to enter the stage in advance")
    case .popArtist(let value):
        print("\(value.vocalist) will need help entering stage right before starting the show")
    }
}
