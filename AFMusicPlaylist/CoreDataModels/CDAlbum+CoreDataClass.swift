
import Foundation
import RealmSwift


public class CDAlbum: Object, UpdatableEntity {
    static var globalName: String { return "CDAlbum" }
    
    @objc dynamic public var name: String?
    @objc dynamic public var artist: String?
    @objc dynamic public var listeners: Int64 = 0
    @objc dynamic public var mediumImageUrl: String?
    @objc dynamic public var largeImageUrl: String?
    @objc dynamic public var releaseDate: Date?
    let songs = List<CDSong>()
}
