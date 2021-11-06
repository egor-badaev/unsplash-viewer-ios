//
//  UnsplashApiService.swift
//  UnsplashViewer
//
//  Created by Egor Badaev on 05.11.2021.
//

import Foundation
import Alamofire

class UnsplashApiAdapter {

    typealias CompletionHandler = (Result<UnsplashApiResponse, Error>) -> Void

    enum RequestType {
        case editorial
        case search(String)
    }

    // MARK: - Properties
    private let baseURL = URL(string: "https://api.unsplash.com")!
    private let headers: HTTPHeaders = [
        "Accept": "application/json",
        "Accept-Version": "v1",
        "Authorization": "Client-ID \(Credentials.apiKey)"
    ]

    // MARK: - Interface
    func fetchPhotos(for request: RequestType, page: Int = 1, completion: @escaping CompletionHandler) {

        var url = baseURL
        var parameters = Parameters()

        if case .search(let query) = request {
            url.appendPathComponent("search")
            parameters["query"] = query
        }
        url.appendPathComponent("photos")

        parameters["per_page"] = AppConfig.API.perPage
        parameters["page"] = page

        switch request {
        case .editorial:
            performFetch(url: url, parameters: parameters, decodable: [UnsplashPhoto].self, completion: completion)
        case .search(_):
            performFetch(url: url, parameters: parameters, decodable: UnsplashSearchResult.self, completion: completion)
        }
    }

    func fetchPhoto(id: String, completion: @escaping (Result<UnsplashPhoto, Error>) -> Void) {

        let url = baseURL.appendingPathComponent("photos").appendingPathComponent(id)

        AF.request(url, method: .get, parameters: nil, headers: headers).responseJSON { response in
            guard let (_, data) = self.validateAndGetResponseData(response: response, completion: { completion(.failure($0)) }) else { return }

            do {
                let photo = try JSONDecoder().decode(UnsplashPhoto.self, from: data)
                completion(.success(photo))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Helper methods
    private func performFetch<T>(url: URL, parameters: Parameters?, decodable: T.Type, completion: @escaping CompletionHandler) where T: Decodable {
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseJSON { response in

            guard let (httpURLResponse, data) = self.validateAndGetResponseData(response: response, completion: { completion(.failure($0)) }) else { return }

            guard let xTotal = httpURLResponse.headers.dictionary["x-total"],
                  let total = Int(xTotal) else {
                      completion(.failure(UnsplashApiError.noTotal))
                      return
                  }
            do {
                let apiResponse = try JSONDecoder().decode(decodable, from: data)
                let validResponse = try UnsplashApiResponse(total: total, response: apiResponse)
                completion(.success(validResponse))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func validateAndGetResponseData(response: AFDataResponse<Any>, completion: (Error) -> Void) -> (HTTPURLResponse, Data)? {
        guard let httpURLResponse = response.response else {
            completion(UnsplashApiError.badResponse)
            return nil
        }

        guard let xLimit = httpURLResponse.headers.dictionary["x-ratelimit-limit"],
              let xRemaining = httpURLResponse.headers.dictionary["x-ratelimit-remaining"],
              let apiLimit = Int(xLimit),
              let apiRemainingLimit = Int(xRemaining) else {
                  completion(UnsplashApiError.badResponse)
                  return nil
              }

        print("API requests remaining: \(apiRemainingLimit)")

        guard apiRemainingLimit > 0 else {
            completion(UnsplashApiError.limitExceeded(apiLimit))
            return nil
        }

        guard httpURLResponse.statusCode == 200 else {
            let error = UnsplashApiError.statusCode(httpURLResponse.statusCode)
            completion(error)
            return nil
        }

        guard let data = response.data else {
            completion(UnsplashApiError.noData)
            return nil
        }

        return (httpURLResponse, data)
    }

}
