//
//  MovieAPI.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation

protocol MovieAPILogic {
    func fetch<T: Codable>(url: URL) async throws -> T
}

struct Constants {
    static let apiKey = "9b94de2654d82e14b60d1cc6143665af"
    static let languageLocale = "it"
    
    static let moviesURL = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=\(languageLocale)&page=\(pageValue)"
    
    ///https://developer.themoviedb.org/reference/movie-top-rated-list
    static let movieRatingURL = "https://api.themoviedb.org/3//movie/top_rated?api_key=\(apiKey)&language=\(languageLocale)&page=\(pageValue)"
    
    static let pageValue = 1
    static let rParameter = "r"
    static let json = "json"
}

class MovieAPI: MovieAPILogic {
    
    func fetch<T: Codable>(url: URL) async throws -> T {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        let object = try JSONDecoder().decode(T.self, from:  try mapResponse(response: (data, response)))
        return object
    }
    
}
