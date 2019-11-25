
import UIKit


class AFStoredAlbumsVC: AFAlbumsVC {
    init() {
        let fetcher: (AFReloadableAlbumList) -> Void = { reloadableList in
            let mapper = AFAlbumUtility()
            let albums: [CDAlbum] = DBUtility.shared.fetchObjects()
            reloadableList.updateSources(with: albums.map { mapper.transformToApiVersion(album: $0) })
        }
        
        super.init(updater: { AFStoredAlbumsUpdater(album: $0) }, fetcher: fetcher)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
