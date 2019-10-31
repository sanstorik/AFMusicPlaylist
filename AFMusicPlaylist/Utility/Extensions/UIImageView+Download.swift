
import UIKit


extension UIImageView {
    func setImageAsyncFrom(url: String, fallback: UIImage? = nil) {
        APIRequest.shared.downloadImage(by: url) {
            self.image = $0 ?? fallback
        }
    }
}
