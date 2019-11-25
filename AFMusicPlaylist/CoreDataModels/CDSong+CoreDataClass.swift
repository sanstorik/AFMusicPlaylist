

import Foundation
import RealmSwift


public class CDSong: Object, UpdatableEntity {
    static var globalName: String { return "CDSong" }
    
    @objc dynamic public var duration: Int64 = 0
    @objc dynamic public var name: String?
    @objc dynamic public var album: CDAlbum?
    let artists = List<String>()
}
