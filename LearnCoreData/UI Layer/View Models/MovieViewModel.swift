//
//  MovieViewModel.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import Combine
import Network

class MoviesViewModel: ObservableObject {
    private var networkConnectivity = NWPathMonitor()
    private var persistenceController: MoviePersistenceController
    
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var error: DataError? = nil
    @Published private(set) var movieRatings: [MovieRating] = []
    
    private let apiService: MovieAPILogic
    
    init(apiService: MovieAPILogic = MovieAPI(),
         persistentController: MoviePersistenceController = MoviePersistenceController()) {
        self.apiService = apiService
        self.persistenceController = persistentController
        networkConnectivity.start(queue: DispatchQueue.global(qos: .userInitiated))
    }
    
    func getMovies() async throws {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            let urlString = Constants.moviesURL
            guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
                throw URLError(.badURL)
            }
            do {
                let movieRoot: MovieRootResult = try await apiService.fetch(url: url)
                Task { @MainActor [weak self] in
                    self?.movies = movieRoot.movies
                    
                    self?.persistenceController.updateAndAddServerDataToCoreData(moviesFromBackend: self?.movies)
                }
            } catch {
                throw error
            }
        default:
            movies = persistenceController.fetchMoviesFromCoreData()
        }
        
    }
    
    func getMovieRatingsVoteAverage() -> Double {
        let voteAverages = movieRatings.prefix(15).map { $0.voteAverage }
        let sum = voteAverages.reduce(0, +)
        return sum / 10
    }
    
    func getMovieRating() async throws {
        switch networkConnectivity.currentPath.status {
        case .satisfied:
            let urlString = Constants.movieRatingURL
            guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
                throw URLError(.badURL)
            }
            do {
                let topRatedMovieRoot: TopRatedMovieRootResult = try await apiService.fetch(url: url)
                Task { @MainActor [weak self] in
                    self?.movieRatings = topRatedMovieRoot.topRatedMovies
                    self?.persistenceController.updateAndAddMovieRatingServerDataToCoreData(movieRatingFromBackend: self?.movieRatings)
                }
            } catch {
                throw error
            }
        default:
            movieRatings = persistenceController.fetchMovieRatingsFromCoreData()
        }
    }
}
