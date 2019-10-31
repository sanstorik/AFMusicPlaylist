

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
        return album.largeImageUrl
    }
    
    var topText: String? {
        return album.name
    }
    
    var bottomText: String? {
        return album.artist
    }
    
    
    let album: AFAlbum
    
    
    init(album: AFAlbum) {
        self.album = album
    }
}
