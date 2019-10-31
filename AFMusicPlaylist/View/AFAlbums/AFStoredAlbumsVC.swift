
import UIKit


class AFStoredAlbumsVC: AFAlbumsVC {
    init() {
        let albums: [CDAlbum] = CDUtility.shared.fetch()
        let fetcher: () -> [AFAlbum] = {
            let mapper = AFAlbumUtility()
            let albums: [CDAlbum] = CDUtility.shared.fetch()
            return albums.map { mapper.transformToApiVersion(album: $0) }
        }
        
        super.init(fetcher: fetcher, updater: { AFStoredAlbumsUpdater(album: $0) })
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
