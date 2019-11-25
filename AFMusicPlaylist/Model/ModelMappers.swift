

import Foundation
import RealmSwift


class AFAlbumUtility {
    func transformToApiVersion(album: CDAlbum) -> AFAlbum {
        let songUtility = AFSongUtility()
        let songs = Array(album.songs).map { songUtility.transformToApiVersion(song: $0) }
        let artist = AFArtist(name: album.artist, images: [], listeners: album.listeners)
        
        let album = AFAlbum(name: album.name, artist: artist, listeners: album.listeners, releaseDate: album.releaseDate,
                songs: songs, images: [AFImage(url: album.largeImageUrl, size: "large")])
        
        return album
    }
    
    
    func storeInDatabase(album: AFAlbum) {
        guard let name = album.name, let artist = album.artist?.name ?? album.artistName,
            let realm = DBUtility.shared.realm else { return }
        
        if let existing = getFromDatabaseBy(name: name, artist: artist) {
            try? realm.write {
                updateDatabaseAlbum(existing, with: album, in: realm)
            }
        } else {
            try? realm.write {
                let cdAlbum = CDAlbum()
                updateDatabaseAlbum(cdAlbum, with: album, in: realm)
                realm.add(cdAlbum)
            }
        }
    }
    
    
    func removeFromDatabase(album: AFAlbum) {
        guard let name = album.name, let artist = album.artist?.name ?? album.artistName else { return }
        if let existing = getFromDatabaseBy(name: name, artist: artist), let realm = DBUtility.shared.realm {
            try? realm.write {
                realm.delete(existing)
            }
        }
    }
    
    
    func getFromDatabaseBy(name: String, artist: String) -> CDAlbum? {
        if let albums: Results<CDAlbum> = DBUtility.shared.fetch(),
            let stored = albums.filter("name == %@ AND artist == %@", name, artist).first {
            return stored
        }
        
        return nil
    }
    
    
    func updateDatabaseAlbum(_ album: CDAlbum, with apiAlbum: AFAlbum, in realm: Realm) {
        album.artist = apiAlbum.artist?.name ?? apiAlbum.artistName
        album.largeImageUrl = apiAlbum.largeImage?.url
        album.listeners = apiAlbum.listeners
        album.name = apiAlbum.name
        album.releaseDate = apiAlbum.releaseDate
        
        album.songs.removeAll()
        for song in apiAlbum.songList?.tracks ?? [] {
            let cdSong = CDSong()
            cdSong.duration = song.duration
            cdSong.name = song.name
            album.songs.append(cdSong)
            realm.add(cdSong)
        }
    }
}


class AFSongUtility {
    func transformToApiVersion(song: CDSong) -> AFSong {
        return AFSong(duration: song.duration, name: song.name, artist: AFSongArtist(name: nil))
    }
}
