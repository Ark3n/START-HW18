import Foundation

enum NetworkError: Error {
    case badURL, invalidData
}

enum Paramert: String {
    case ornithopter = "Ornithopter"
    case blackLotus = "Black%20Lotus"
}

struct CardModel: Codable {
    let cards: [Card]
    struct Card: Codable {
        let name: String
        let manaCost: String
        let cmc: Int
        let type: String
    }
}

class NetworkService {
    static let shared = NetworkService()
    private init() { }
    
    
    private func getURL(param: Paramert) -> URL? {
        let port = "https://"
        let domain = "api.magicthegathering.io/v1/"
        let endpoit = "cards"
        let param = "?name=" + param.rawValue
        let urlStr = port + domain + endpoit + param
        let url = URL(string: urlStr)
        return url
    }
    
    func fetchData(param: Paramert, completion: @escaping(Result<CardModel, Error>) ->()) {
        guard let url = getURL(param: param) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error {
                    completion(.failure(error))
                }
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let cardData = try decoder.decode(CardModel.self, from: data)
                completion(.success(cardData))
            } catch {
                completion(.failure(NetworkError.invalidData))
            }
        }.resume()
    }
}

func printCardInfo(param: Paramert) {
    NetworkService.shared.fetchData(param: param) { result in
        switch result {
        case .success(let cards):
            let card = cards.cards[0]
            print("name: \(card.name)")
            print("cmc: \(card.cmc)")
            print("mana cost: \(card.manaCost)")
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

printCardInfo(param: Paramert.ornithopter)
