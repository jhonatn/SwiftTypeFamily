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
