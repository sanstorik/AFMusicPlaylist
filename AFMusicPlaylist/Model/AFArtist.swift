
import Foundation



struct AFArtist: Codable {
    let name: String?
    let images: [AFImage]
    let listeners: Int64
    
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case images = "image"
        case listeners = "listeners"
    }
    
    
    var largeImage: AFImage? {
        return images.first { $0.size == "large" } ?? images.first { $0.size == "mega" } ?? images.first { $0.url != nil }
    }
    
    
    var smallImage: AFImage? {
        return images.first { $0.size == "small" } ?? images.first { $0.size == "medium" } ?? images.first { $0.url != nil }
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        images = (try? container.decodeIfPresent([AFImage].self, forKey: .images)) ?? []
        
        if let nListeners = try? container.decodeIfPresent(String.self, forKey: .listeners) {
            listeners = Int64(nListeners) ?? 0
        } else {
            listeners = 0
        }
    }
    
    
    init(name: String?, images: [AFImage], listeners: Int64) {
        self.name = name
        self.images = images
        self.listeners = listeners
    }
}
