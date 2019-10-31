
import UIKit
import Alamofire
import AlamofireImage


class APIRequest {
    static let shared = APIRequest()
    
    private var imageCache = AutoPurgingImageCache()
    private var processingImages = [String: AFImageDownloadEvent]()
    
    private init() { }
    
    
    func downloadImage(by url: String, completion: @escaping (UIImage?) -> Void) {
        if let cached = imageCache.image(withIdentifier: url) {
            completion(cached)
            return
        }
        
        
        if let process = processingImages[url] {
            process.addObserver(url) {
                completion($0)
            }
            
            return
        }
        
        
        let processEvent = AFImageDownloadEvent()
        processingImages[url] = processEvent
        
        Alamofire.request(url).responseImage { response in
            DispatchQueue.main.async {
                if let image = response.result.value {
                    self.imageCache.add(image, withIdentifier: url)
                    
                    completion(image)
                    processEvent.notifyObservers(image)
                } else {
                    completion(nil)
                    processEvent.notifyObservers(nil)
                }
                
                processEvent.removeObserver(url)
                self.processingImages[url] = nil
            }
        }
    }
}
