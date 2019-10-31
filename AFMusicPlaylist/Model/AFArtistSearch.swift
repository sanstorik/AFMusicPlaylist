
import Foundation


struct AFArtistSearch: Codable {
    let results: AFArtistSearchResult
}


struct AFArtistSearchResult: Codable {
    let artistmatches: AFArtistSearchList
}


struct AFArtistSearchList: Codable {
    let artists: [AFArtist]
    
    enum CodingKeys: String, CodingKey {
        case artists = "artist"
    }
}
