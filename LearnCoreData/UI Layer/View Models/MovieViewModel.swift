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
    private var persistenceController = MoviePersistenceController()
    private var moviesFetchRequest = MovieCD.fetchRequest()
    
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var error: DataError? = nil
    @Published private(set) var movieRatings: [MovieRating] = []
    
    private let apiService: MovieAPILogic
    
    init(apiService: MovieAPILogic = MovieAPI()) {
        self.apiService = apiService
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
                    
                    // 0. Prepare incoming server side movies ID list and dictionary
                    var moviesIdDict: [Int: Movie] = [:]
                    var moviesIdList: [Int] = []
                    
                    
                    guard let movies = self?.movies, !movies.isEmpty else {
                        return
                    }
                    
                    for movie in movies {
                        moviesIdDict[movie.id] = movie
                    }
                        
                    moviesIdList = movies.map { $0.id }
                    
                    // 1. Get all the movies that match incoming server side movied ID
                    // Find any existing movies in our local core data
                    
                    guard let moviesFetchRequest = self?.moviesFetchRequest else {
                        return
                    }
                    moviesFetchRequest.predicate = NSPredicate(format: "id IN %@", moviesIdList)

                    // 2. Make a fetch request using predicate
                    guard let managedObjectContext = self?.persistenceController.persistentContainer.viewContext else {
                        return
                    }
                    
                    let moviesCDList = try? managedObjectContext.fetch(moviesFetchRequest)
                    guard let moviesCDList = moviesCDList else {
                        return
                    }
        
                    var moviesIdListInCD: [Int] = []
                    
                    // 3. Update all matching movies to have the same data
                    for movieCD in moviesCDList {
                        moviesIdListInCD.append(Int(movieCD.id))
                        if let movie = moviesIdDict[Int(movieCD.id)] {
                            if movie.overview != movieCD.overview {
                                movieCD.setValue(movie.overview, forKey: "overview")
                            }
                            if movie.title != movieCD.title {
                                movieCD.setValue(movie.title, forKey: "title")
                            }
                            if movie.imageUrlSuffix != movieCD.imageUrlSuffix {
                                movieCD.setValue(movie.imageUrlSuffix, forKey: "imageUrlSuffix")
                            }
                            if movie.releaseDate != movieCD.releaseDate {
                                movieCD.setValue(movie.releaseDate, forKey: "releaseDate")
                            }
                            
                        }
                    }
                    
                    // 4. Add new objects coming from the backend/server side
                    for movie in movies {
                        if !moviesIdListInCD.contains(movie.id) {
                            let movieCD = MovieCD(context: managedObjectContext)
                            movieCD.id = Int64(movie.id)
                            movieCD.title = movie.title
                            movieCD.overview = movie.overview
                            movieCD.releaseDate = movie.releaseDate
                            movieCD.imageUrlSuffix = movie.imageUrlSuffix
                        }
                    }
                    
                    // 5. Save changes
                    try? managedObjectContext.save()
                }
            } catch {
                throw error
            }
        default:
            do {
                let moviesCDList = try persistenceController.persistentContainer.viewContext.fetch(moviesFetchRequest)
                
                var convertedMovies: [Movie] = []
                for movieCD in moviesCDList {
                    let movie = Movie(id: Int(movieCD.id), title: movieCD.title ?? "", releaseDate: movieCD.releaseDate ?? "", imageUrlSuffix: movieCD.imageUrlSuffix ?? "", overview: movieCD.overview ?? "")
                    convertedMovies.append(movie)
                }
                movies = convertedMovies
            } catch {
                self.error = .coreData("Could not retrieve movies from core data")
            }
            
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
                }
            } catch {
                throw error
            }
        default:
            break
        }
    }
}
