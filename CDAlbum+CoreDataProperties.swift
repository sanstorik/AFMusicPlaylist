
import Foundation
import CoreData


extension CDAlbum {
    @NSManaged public var name: String?
    @NSManaged public var artist: String?
    @NSManaged public var listeners: Int64
    @NSManaged public var mediumImageUrl: String?
    @NSManaged public var largeImageUrl: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var songs: Set<CDSong>
}
