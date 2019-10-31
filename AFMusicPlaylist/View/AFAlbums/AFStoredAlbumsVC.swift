
import UIKit


class AFStoredAlbumsVC: AFAlbumsVC {
    init() {
        let albums = [AFAlbum(name: "First"), AFAlbum(name: "second"), AFAlbum(name: "third")]
        super.init(albums: albums, updater: { AFStoredAlbumsUpdater(album: $0) })
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
