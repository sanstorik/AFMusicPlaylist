

import Foundation
import CoreData


extension CDSong {
    @NSManaged public var duration: Int64
    @NSManaged public var name: String?
    @NSManaged public var artists: [String]?
    @NSManaged public var album: CDAlbum?
}
