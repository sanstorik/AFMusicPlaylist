
import UIKit


class AFStoredAlbumsVC: AFAlbumsVC {
    init() {
        let mapper = AFAlbumUtility()
        let albums: [CDAlbum] = CDUtility.shared.fetch()
        
        super.init(albums: albums.map { mapper.transformToApiVersion(album: $0)},
                   updater: { AFStoredAlbumsUpdater(album: $0) })
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
