//
//  NetworkCall.swift
//  DoG-Finder
//
//  Created by Ghaffar on 10/12/23.
//


import Foundation
import NetworkHelper


struct DogAPIClient {
    static func fetchDogs(pageNumber:String, completion: @escaping (Result<[DogImage], AppError>) -> ())    {
        
        let endpointURLString = envoriment.BASE_URL + pageNumber
        
        guard let url = URL(string: endpointURLString)
            else    {
                completion(.failure(.badURL(endpointURLString)))
                return
        }
        
        let request = URLRequest(url: url)
        NetworkHelper.shared.performDataTask(with: request) { (result) in
            switch result   {
            case .failure(let appError):
                print(appError)
            case .success(let data):
                do  {
                    let results = try JSONDecoder().decode(RandomDogInfo.self, from: data)
                        completion(.success(results.message))
                }
                catch   {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
    }
}
