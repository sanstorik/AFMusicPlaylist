
import Foundation



struct AFArtist: Codable {
    let name: String?
    let images: [AFImage]
    
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case images = "image"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        images = (try? container.decodeIfPresent([AFImage].self, forKey: .images)) ?? []
    }
    
    
    init(name: String?, images: [AFImage]) {
        self.name = name
        self.images = images
    }
}
