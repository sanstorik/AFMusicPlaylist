

import UIKit


enum AFMusicPlaylistAPIAction: APIAction {
    case artistAlbums(artist: String)
    case albumDetailed(name: String, artist: String)
    case artistSearch(artist: String, limit: Int, page: Int)
    
    
    var baseUrl: String {
        return "http://ws.audioscrobbler.com/2.0/"
    }
    
    
    var path: String {
        return ""
    }
    
    
    var params: [String : Any] {
        switch self {
        case .artistAlbums(let artist):
            return paramsBy(adding: ["artist": artist, "method": "artist.gettopalbums"])
        case .albumDetailed(let name, let artist):
            return paramsBy(adding: ["artist": artist, "album": name, "method": "album.getinfo"])
        case .artistSearch(let artist, let limit, let page):
            return paramsBy(adding: ["artist": artist, "limit": String(limit), "page": String(page),
                                     "method": "artist.search"])
        }
    }
    
    
    var method: APIMethod {
        return .get
    }
    
    
    var token: String? {
        return nil
    }
    
    
    private func paramsBy(adding additional: [String: String]) -> [String: String] {
        /* API_KEY is exposed only for educational purposes */
        var combined: [String: String] = [
            "api_key": "fd7124147c422c53b29034c7b8fb078f",
            "format": "json"
        ]
        
        for param in additional {
            combined[param.key] = param.value
        }
        
        return combined
    }
}
