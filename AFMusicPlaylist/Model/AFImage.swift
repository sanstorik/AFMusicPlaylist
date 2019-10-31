
import Foundation


struct AFImage: Codable {
    let url: String?
    let size: String
    
    enum CodingKeys: String, CodingKey {
        case url = "#text"
        case size = "size"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try? container.decodeIfPresent(String.self, forKey: .url)
        size = (try? container.decodeIfPresent(String.self, forKey: .size)) ?? ""
    }
    
    
    init(url: String?, size: String) {
        self.url = url
        self.size = size
    }
}
