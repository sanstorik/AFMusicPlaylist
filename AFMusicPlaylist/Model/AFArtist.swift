
import Foundation



struct AFArtist: Codable {
    let name: String
    let imageUrl: String?
    let smallImageUrl: String?
    
    
    enum CodingKeys: String, CodingKey {
        case name = "first_name"
        case imageUrl = "last_name"
        case smallImageUrl
    }
}
