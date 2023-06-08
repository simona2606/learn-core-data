//
//  Movie.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation

struct MovieRootResult: Codable {
    let page: Int
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case page
        case movies = "results"
    }
}

struct Movie: Codable, Identifiable {
    struct Constants {
        static let baseImageUrl = "https://image.tmdb.org/t/p/"
        static let logoSize = "w45"
        static let largeImageSIze = "w500"
    }
    
    var id: Int
    let title: String
    let releaseDate: String
    let imageUrlSuffix: String
    let overview: String
    
    func getThumbnailImageUrl() -> String {
        return "\(Constants.baseImageUrl)\(Constants.logoSize)\(imageUrlSuffix)"
    }
    
    func getLargeImageUrl() -> String {
        return "\(Constants.baseImageUrl)\(Constants.largeImageSIze)\(imageUrlSuffix)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case overview
        case imageUrlSuffix = "poster_path"
    }
}
