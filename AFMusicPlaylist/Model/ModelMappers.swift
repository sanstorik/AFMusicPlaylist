

import Foundation


class AFAlbumUtility {
    func transformToApiVersion(album: CDAlbum) -> AFAlbum {
        let songUtility = AFSongUtility()
        let songs = album.songs.map { songUtility.transformToApiVersion(song: $0) }
        let album = AFAlbum(name: album.name, artist: album.artist, listeners: album.listeners,
                       mediumImageUrl: album.mediumImageUrl, largeImageUrl: album.largeImageUrl,
                       releaseDate: album.releaseDate, songs: songs)
        
        return album
    }
}


class AFSongUtility {
    func transformToApiVersion(song: CDSong) -> AFSong {
        return AFSong(duration: song.duration, name: song.name, artists: song.artists)
    }
}
