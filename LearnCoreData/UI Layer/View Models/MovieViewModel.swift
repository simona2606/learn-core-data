//
//  MovieViewModel.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import Combine

class MoviesViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var error: DataError? = nil
    @Published private(set) var movieRatings: [MovieRating] = []
    
    private let apiService: MovieAPILogic
    
    init(apiService: MovieAPILogic = MovieAPI()) {
        self.apiService = apiService
    }
    
    func getMovies() async throws {
        let urlString = Constants.moviesURL
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            throw URLError(.badURL)
        }
        do {
            let movieRoot: MovieRootResult = try await apiService.fetch(url: url)
            Task { @MainActor [weak self] in
                self?.movies = movieRoot.movies
            }
        } catch {
            throw error
        }
    }
    
    func getMovieRatingsVoteAverage() -> Double {
        let voteAverages = movieRatings.prefix(15).map { $0.voteAverage }
        let sum = voteAverages.reduce(0, +)
        return sum / 10
    }
    
    func getMovieRating() async throws {
        let urlString = Constants.movieRatingURL
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            throw URLError(.badURL)
        }
        do {
            let topRatedMovieRoot: TopRatedMovieRootResult = try await apiService.fetch(url: url)
            Task { @MainActor [weak self] in
                self?.movieRatings = topRatedMovieRoot.topRatedMovies
            }
        } catch {
            throw error
        }
    }
}
