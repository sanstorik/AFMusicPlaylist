
import UIKit


extension UIImageView {
    func setImageAsyncFrom(url: String) {
        APIRequest.shared.downloadImage(by: url) {
            self.image = $0
        }
    }
}
