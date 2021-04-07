
import Foundation

enum UserDefaultKeys: String {
    case Locations
}

enum RequestType: String {
    case POST, PUT, GET
}

struct ServiceRequest {
    var url: URL
    var headerFields: [String: String]?
    var httpMethod: String
    var data: Data?
}

class ServiceUtils {
    
     static var shared: ServiceUtils = ServiceUtils()
     var baseURL: String = "api.openweathermap.org/data/2.5"
     var lasRequest : URLRequest?
    
    func createRequest(req: ServiceRequest) throws -> URLRequest {
        var request = URLRequest(url: req.url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 120.0)
            if let headers = req.headerFields {
                request.allHTTPHeaderFields = headers
            }
            request.httpMethod = req.httpMethod
            if let data = req.data {
                request.httpBody = data
            }
            return request
    }
    
    func performTask(for request: URL, completion: @escaping (Result<(URLResponse, Data), (Error)>) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            let session = URLSession.shared
            //session.data
            session.dataTask(with: request) { (data, response, error) in
                if let err = error {
                    completion(.failure(err))
                    return
                }
                guard let response = response, let data = data else {
                    let error = NSError(domain: "error", code: 0, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                completion(.success((response,data)))
                }.resume()
        }
    }
  
    func verifyStatus(response: URLResponse) -> NetworkResponse {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            return .failed
        }
        
        switch statusCode {
        case 200:
            return .success
        case 401...500:
            return .authenticationError
        case 501...599:
            return .badRequest
        case 600:
            return .outdated
        default:
            return .failed
        }
        
    }
   
}
enum NetworkResponse: String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad Request"
    case outdated = "The url you requested is outdated."
    case failed = "Network Request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
    
}
