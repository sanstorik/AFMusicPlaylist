

import UIKit
import Alamofire


protocol APIAction {
    var baseUrl: String { get }
    var path: String { get }
    var params: [String: Any] { get }
    var method: APIMethod { get }
    var token: String? { get }
}



enum APIDataResponse {
    case noInternet
    case failure
    case notAuthorized
    case error(json: [String: Any])
    case success(json: [String: Any], data: Data)
}



class APIActionProvider<T: APIAction> {
    func request(action: T, completionHandler: @escaping (APIDataResponse) -> ()) {
        var headers = ["Content-Type": "application/json; charset=UTF-8"]
        if let token = action.token {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        var url = action.baseUrl + action.path
        addGetParamsFor(url: &url, action: action)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = action.method.string
        request.allHTTPHeaderFields = headers
        
        if action.method == .post || action.method == .put {
            request.httpBody = try? JSONSerialization.data(withJSONObject: action.params)
        }
  
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let nJson = json as? [String: Any], let data = response.data {
                    completionHandler(.success(json: nJson, data: data))
                } else {
                    completionHandler(.error(json: [:]))
                }
            case .failure(let error):
                print(error)
                completionHandler(.error(json: [:]))
            }
        }
    }
    
    
    private func addGetParamsFor(url: inout String, action: APIAction) {
          if action.params.count > 0 {
              url += "?"
              
              action.params.forEach { (key, value) in
                  url += "\(key)=\(value)&"
              }
              
              url.removeLast()
          }
      }
}


enum APIMethod {
    case get, post, put, patch, delete
    
    var string: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
    
    var alamofire: HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .patch:
            return .patch
        case .delete:
            return .delete
        }
    }
}


enum APIResponse {
    case success, noInternet, error
}

enum DataResponse {
    case success(Data), noInternet, error
}
