

import Foundation

struct AFListSongHolder: Codable {
    let tracks: [AFSong]
    
    enum CodingKeys: String, CodingKey {
        case tracks = "track"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tracks = (try? container.decodeIfPresent([AFSong].self, forKey: .tracks)) ?? []
    }
    
    
    init(songs: [AFSong]) {
        self.tracks = songs
    }
}


struct AFSong: Codable {
    let duration: Int64
    let name: String?
    let artist: AFSongArtist?
    
    enum CodingKeys: String, CodingKey {
        case duration = "duration"
        case name = "name"
        case artist = "artist"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        artist = try? container.decodeIfPresent(AFSongArtist.self, forKey: .artist)
        
        if let nDuration = try? container.decodeIfPresent(String.self, forKey: .duration) {
            duration = Int64(nDuration) ?? 0
        } else {
            duration = 0
        }
    }
    
    
    init(duration: Int64, name: String?, artist: AFSongArtist?) {
        self.duration = duration
        self.name = name
        self.artist = artist
    }
}


struct AFSongArtist: Codable {
    let name: String?
}
