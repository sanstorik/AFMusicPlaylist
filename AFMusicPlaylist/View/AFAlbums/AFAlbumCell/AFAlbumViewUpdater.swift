

import Foundation


protocol AFAlbumViewUpdater {
    var imageUrl: String? { get}
    var topText: String? { get }
    var bottomText: String? { get }
    var album: AFAlbum { get }
    
    init(album: AFAlbum)
}


struct AFStoredAlbumsUpdater: AFAlbumViewUpdater {
    var imageUrl: String? {
        return album.largeImage?.url
    }
    
    
    var topText: String? {
        if let name = album.name, !name.isEmpty {
            return name
        }
        
        return "No name"
    }
    
    
    var bottomText: String? {
        if let text = album.artist?.name, !text.isEmpty {
            return text
        } else if let text = album.artistName, !text.isEmpty {
            return text
        }
        
        return "No artist"
    }
    
    
    let album: AFAlbum
    
    
    init(album: AFAlbum) {
        self.album = album
    }
}


struct AFArtistsAlbumsUpdater: AFAlbumViewUpdater {
    var imageUrl: String? {
        return album.largeImage?.url
    }
    
    
    var topText: String? {
        if let name = album.name, !name.isEmpty {
            return name
        }
        
        return "No name"
    }
    
    
    var bottomText: String? {
        return "\(album.listeners) \(peoplePluralForm(count: album.listeners)) to it with you."
    }
    
    
    let album: AFAlbum
    
    
    init(album: AFAlbum) {
        self.album = album
    }
    
    
    func peoplePluralForm(count: Int64) -> String {
        switch count {
        case 1:
            return "person listens"
        default:
            return "people listen"
        }
    }
}
