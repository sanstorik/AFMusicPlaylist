
import UIKit


class AFStoredAlbumsVC: AFAlbumsVC {
    init() {
        let mapper = AFAlbumUtility()
        let albums: [CDAlbum] = CDUtility.shared.fetch()
        
        /*let album1 = CDAlbum(context: CDUtility.shared.context)
        album1.artist = "Bieber"
        album1.largeImageUrl = "https://lastfm.freetls.fastly.net/i/u/174s/459de169a528034752b912fcc077a20a.png"
        album1.mediumImageUrl = "https://lastfm.freetls.fastly.net/i/u/174s/0c8f97586cbb46a3875ee70eaa7e7cb0.png"
        album1.releaseDate = Date()
        album1.name = "Cold water"
        
        CDUtility.shared.context.saveContext()*/
        
        super.init(albums: albums.map { mapper.transformToApiVersion(album: $0)},
                   updater: { AFStoredAlbumsUpdater(album: $0) })
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
