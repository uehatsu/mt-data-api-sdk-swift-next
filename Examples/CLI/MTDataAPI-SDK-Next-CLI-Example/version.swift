import Foundation
import Combine
import MTDataAPI_SDK_Next

@main
public struct FetchVersion {
    public static func main() {
        var cancellable = Set<AnyCancellable>()
        
        var apiClient = DataAPI()
        apiClient.apiBaseURL = "https://movabletype.net/.data-api"
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        apiClient.version()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("finished!!")
                    dispatchGroup.leave()
                    break
                case .failure(let e):
                    print(e.localizedDescription)
                    dispatchGroup.leave()
                    break
                }
            }, receiveValue: { version in
                print("EndpointVersion : \(version.endpointVersion.rawValue)")
                print("ApiVersion      : \(version.apiVersion.rawValue)")
            })
            .store(in: &cancellable)
        
        dispatchGroup.wait()
    }
}
