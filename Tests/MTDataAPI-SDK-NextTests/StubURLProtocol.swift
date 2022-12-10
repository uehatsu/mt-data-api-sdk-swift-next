import Foundation

// 参考 : https://zenn.dev/satococoa/articles/e8fd7b26bb2268
// 「URLProtocol を使って URLSession の stub を作る」

typealias RequestHandler = ((URLRequest) throws -> (HTTPURLResponse, Data?))

class StubURLProtocol: URLProtocol {
    static var requestHandler: RequestHandler?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override func startLoading() {
        guard let handler = Self.requestHandler else {
            fatalError("Handler is unavailable")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch let e {
            client?.urlProtocol(self, didFailWithError: e)
        }
    }
    override func stopLoading() {}
}
