

import Foundation


class AFAlbumUtility {
    func transformToApiVersion(album: CDAlbum) -> AFAlbum {
        let songUtility = AFSongUtility()
        let songs = album.songs.map { songUtility.transformToApiVersion(song: $0) }
        let artist = AFArtist(name: album.artist, images: [], listeners: album.listeners)
        let album = AFAlbum(name: album.name, artist: artist, listeners: album.listeners, releaseDate: album.releaseDate,
                songs: songs, images: [AFImage(url: album.largeImageUrl, size: "large")])
        
        return album
    }
    
    
    func storeInDatabase(album: AFAlbum) {
        guard let name = album.name, let artist = album.artist?.name ?? album.artistName else { return }
        
        if let existing = getFromDatabaseBy(name: name, artist: artist) {
            updateDatabaseAlbum(existing, with: album)
        } else {
            let cdAlbum = CDAlbum(context: CDUtility.shared.context)
            updateDatabaseAlbum(cdAlbum, with: album)
        }
        
        CDUtility.shared.context.saveContext()
    }
    
    
    func removeFromDatabase(album: AFAlbum) {
        guard let name = album.name, let artist = album.artist?.name ?? album.artistName else { return }
        if let existing = getFromDatabaseBy(name: name, artist: artist) {
            CDUtility.shared.context.delete(existing)
            CDUtility.shared.context.saveContext()
        }
    }
    
    
    func getFromDatabaseBy(name: String, artist: String) -> CDAlbum? {
        let predicate = NSPredicate(format: "name == %@ AND artist == %@", name, artist)
        let albums: [CDAlbum] = CDUtility.shared.objectsBy(predicate: predicate)
        
        return albums.first
    }
    
    
    func updateDatabaseAlbum(_ album: CDAlbum, with apiAlbum: AFAlbum) {
        album.artist = apiAlbum.artist?.name ?? apiAlbum.artistName
        album.largeImageUrl = apiAlbum.largeImage?.url
        album.listeners = apiAlbum.listeners
        album.name = apiAlbum.name
        album.releaseDate = apiAlbum.releaseDate
        
        album.songs.removeAll()
        for song in apiAlbum.songList?.tracks ?? [] {
            let cdSong = CDSong(context: CDUtility.shared.context)
            cdSong.duration = song.duration
            cdSong.name = song.name
            cdSong.artists = []
            album.songs.insert(cdSong)
        }
    }
}


class AFSongUtility {
    func transformToApiVersion(song: CDSong) -> AFSong {
        return AFSong(duration: song.duration, name: song.name, artist: AFSongArtist(name: nil))
    }
}
