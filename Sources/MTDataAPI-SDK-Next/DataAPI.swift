import Foundation
import Combine

public struct DataAPI {
    
    // MARK: - Properties
    
    let session: URLSession
    
    public var endpointVersion = "v3"
    public var apiBaseURL = "http://localhost/cgi-bin/MT-6.1/mt-data-api.cgi"
    fileprivate var apiURL: String {
        "\(apiBaseURL)/\(endpointVersion)"
    }
    
    public init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
}

// MARK: - Enums

extension DataAPI {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
}

// MARK: - Entities

fileprivate protocol Entity: Codable, Equatable {
}

extension DataAPI {
    
    public struct Version: Entity {
        public let endpointVersion: DataAPI.EndpointVersion
        public let apiVersion: APIVersion
    }
    
}

// MARK: - ValueObjects

fileprivate protocol ValueObject: Codable, Equatable, RawRepresentable {
    associatedtype AssociatedType
    
    var rawValue: AssociatedType { get }
    
    init(rawValue: AssociatedType)
}

fileprivate extension ValueObject where Self.AssociatedType: CustomStringConvertible {
    var description: String {
        return rawValue.description
    }
}

extension DataAPI {
    
    public struct EndpointVersion: ValueObject {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public struct APIVersion: ValueObject {
        public let rawValue: Float

        public init(rawValue: Float) {
            self.rawValue = rawValue
        }
    }
    
}

// MARK: - Methods

extension DataAPI {
    
    fileprivate func actionCommon<T: Decodable>(_ method: HTTPMethod, url: URL) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    fileprivate func get<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
        return actionCommon(.get, url: url)
    }
    
}

// MARK: - API Methods

extension DataAPI {
    
    // MARK: - version
    public func version() -> AnyPublisher<Version, Error> {
        guard let url = URL(string: apiBaseURL + "/version") else {
            return Fail(error: NSError(domain: "Invalid version API URL", code: -1)).eraseToAnyPublisher()
        }
        
        return get(url)
    }
    
}
