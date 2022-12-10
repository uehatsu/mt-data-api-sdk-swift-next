import XCTest
import Combine
@testable import MTDataAPI_SDK_Next

final class DataAPITests: XCTestCase {
    
    var api: DataAPI = DataAPI()
    var cancellable = Set<AnyCancellable>()
    
    func testShouldGetValidEndpointVersion() throws {
        XCTAssertEqual(api.endpointVersion, "v3")
    }
    
    func testShouldGetValidApiBaseURL() throws {
        XCTAssertEqual(api.apiBaseURL, "http://localhost/cgi-bin/MT-6.1/mt-data-api.cgi")
    }
    
    func testCanSetEndpointVersion() throws {
        api.endpointVersion = "v4"
        XCTAssertEqual(api.endpointVersion, "v4")
    }
    
    func testCanSetApiBaseURL() throws {
        api.apiBaseURL = "https://movabletype.net/.data-api"
        XCTAssertEqual(api.apiBaseURL, "https://movabletype.net/.data-api")
    }
    
    func testCanDecodeVersion() throws {
        // 元々のJSON文字列
        let json = """
                   {"endpointVersion":"v4","apiVersion":4}
                   """
        // JSON文字列から作製したDataオブジェクトインスタンス
        let jsonData = json.data(using: .utf8)!
        
        // デコード実装
        let version = try JSONDecoder().decode(DataAPI.Version.self, from: jsonData)
        
        // 値チェック
        XCTAssertEqual(version, DataAPI.Version(endpointVersion: .init(rawValue: "v4"), apiVersion: .init(rawValue: 4)))
    }
    
    func testCanEncodeVersion() throws {
        // Versionオブジェクトインスタンス
        let version = DataAPI.Version(endpointVersion: .init(rawValue: "v4"), apiVersion: .init(rawValue: 4))
        // エンコード実装
        let jsonData = try JSONEncoder().encode(version)
        
        // Dataオブジェクトインスタンスから文字列へ変換
        let json = String(data: jsonData, encoding: .utf8)!
        
        // 値チェック（ここではjson文字列のなかに、特定の文字列が含まれているかをチェックしている）
        XCTAssert(json.contains("\"apiVersion\":4"))
        XCTAssert(json.contains("\"endpointVersion\":\"v4\""))
    }
    
    func testShouldGetValidVersionInstance() async throws {
        let expectation = expectation(description: "testShouldGetValidVersionInstance")
        
        StubURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/2", headerFields: ["Content-Type": "application/json"])!
            let json = """
                       {"endpointVersion":"v4","apiVersion":4}
                       """
            let jsonData = json.data(using: .utf8)
            return (response, jsonData)
        }
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: config)
        
        var apiClient = DataAPI(session: session)
        apiClient.apiBaseURL = "https://www.example.com/.data-api"
        
        apiClient.version()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let e):
                    print(e.localizedDescription)
                    XCTFail()
                }
            }, receiveValue: { version in
                // 値チェック
                XCTAssertEqual(version, DataAPI.Version(endpointVersion: .init(rawValue: "v4"), apiVersion: .init(rawValue: 4)))
                expectation.fulfill()
            })
            .store(in: &cancellable)
        wait(for: [expectation], timeout: 10)
    }
}
