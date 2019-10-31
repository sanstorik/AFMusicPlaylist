
import Foundation


struct AFTopAlbums: Codable {
    let topalbums: AFSingleTopAlbum
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        topalbums = try container.decode(AFSingleTopAlbum.self, forKey: .topalbums)
    }
}


struct AFSingleTopAlbum: Codable {
    let album: [AFAlbum]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        album = try container.decodeIfPresent([AFAlbum].self, forKey: .album) ?? []
    }
}


struct AFAlbumDetailed: Codable {
    let album: AFAlbum?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        album = try? container.decodeIfPresent(AFAlbum.self, forKey: .album)
    }
}


struct AFAlbum: Codable {
    let name: String?
    let artist: AFArtist?
    let listeners: Int64
    let releaseDate: Date?
    let songList: AFListSongHolder?
    let images: [AFImage]
    let artistName: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case images = "image"
        case artist = "artist"
        case listeners = "listeners"
        case songList = "tracks"
        case releaseDate = "releasedate"
    }
    
    var largeImage: AFImage? {
        return images.first { $0.size == "large" } ?? images.first { $0.size == "mega" } ?? images.first
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        artist = try? container.decodeIfPresent(AFArtist.self, forKey: .artist)
        songList = try? container.decodeIfPresent(AFListSongHolder.self, forKey: .songList)
        images = (try? container.decodeIfPresent([AFImage].self, forKey: .images)) ?? []
        releaseDate = try? container.decodeIfPresent(Date.self, forKey: .releaseDate)
        
        if let nListeners = try? container.decodeIfPresent(String.self, forKey: .listeners) {
            listeners = Int64(nListeners) ?? 0
        } else {
            listeners = 0
        }
         
        if let nArtistName = try? container.decodeIfPresent(String.self, forKey: .artist) {
            artistName = nArtistName
        } else {
            artistName = artist?.name
        }
    }
    
    
    init(name: String?, artist: AFArtist, listeners: Int64, releaseDate: Date?, songs: [AFSong], images: [AFImage]) {
        self.name = name
        self.artist = artist
        self.listeners = listeners
        self.songList = AFListSongHolder(songs: songs)
        self.images = images
        self.releaseDate = releaseDate
        self.artistName = artist.name
    }
}
