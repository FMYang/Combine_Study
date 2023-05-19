import Foundation
import PlaygroundSupport
import Combine

struct API {
    enum Error: LocalizedError {
        case addressUnreachable(URL)
        case invalidReponse
        
        var errorDescription: String? {
            switch self {
            case .invalidReponse: return "The server responded with garbage."
            case .addressUnreachable(let url): return "\(url.absoluteString) is unreachable"
            }
        }
    }
    
    enum EndPoint {
        static let baseURL = URL(string: "http://hacker-news.firebaseio.com/v0/")!
        
        case stories
        case story(Int)
        
        var url: URL {
            switch self {
            case .stories:
                return EndPoint.baseURL.appendingPathComponent("newstories.json")
            case .story(let id):
                return EndPoint.baseURL.appendingPathComponent("item/\(id).json")
            }
        }
    }
    
    var maxStories = 10
    
    private let decoder = JSONDecoder()
    
    private let apiQueue = DispatchQueue(label: "API",
                                         qos: .default,
                                         attributes: .concurrent)
    
    func story(id: Int) -> AnyPublisher<Story, Error> {
        URLSession.shared
            .dataTaskPublisher(for: EndPoint.story(id).url)
            .receive(on: apiQueue)
            .map(\.data)
            .decode(type: Story.self, decoder: decoder)
            .catch { _ in Empty<Story, Error>() }
            .eraseToAnyPublisher()
    }
    
    func mergeStories(id storyIDs: [Int]) -> AnyPublisher<Story, Error> {
        let storyIDs = Array(storyIDs.prefix(maxStories))
        
        precondition(!storyIDs.isEmpty)
        
        let initialPublisher = story(id: storyIDs[0])
        let remainder = Array(storyIDs.dropFirst())
        
        return remainder.reduce(initialPublisher) { (combined, id) -> AnyPublisher<Story, Error> in
            return combined
                .merge(with: story(id: id))
                .eraseToAnyPublisher()
        }
    }
    
    func stories() -> AnyPublisher<[Story], Error> {
        URLSession.shared.dataTaskPublisher(for: EndPoint.stories.url)
            .map { $0.0 }
            .decode(type: [Int].self, decoder: decoder)
            .mapError { error in
                switch error {
                case is URLError:
                    return Error.addressUnreachable(EndPoint.stories.url)
                default: return Error.invalidReponse
                }
            }
            .filter { !$0.isEmpty }
            .flatMap { storyIDs in
                return self.mergeStories(id: storyIDs)
            }
            .scan([]) { (stories, story) -> [Story] in
                return stories + [story]
            }
            .map { stories in
                return stories.sorted()
            }
            .eraseToAnyPublisher()
    }
}

let api = API()
var subscriptions = [AnyCancellable]()

//api.story(id: 1000)
//    .sink(receiveCompletion: { print($0) },
//          receiveValue: { print($0) })
//    .store(in: &subscriptions)

api.stories()
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print("xxx \($0)") })
    .store(in: &subscriptions)
