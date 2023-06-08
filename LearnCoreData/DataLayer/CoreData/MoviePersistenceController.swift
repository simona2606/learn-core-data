//
//  MoviePersistenceController.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import CoreData

class MoviePersistenceController: ObservableObject {
    var persistentContainer = NSPersistentContainer(name: "MovieCD")
    private var moviesFetchRequest = MovieCD.fetchRequest()
    private var movieRatingsFetchRequest = MovieRatingCD.fetchRequest()
    
    init() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("error = \(error)")
            }  
        }
    }
    
    func updateAndAddServerDataToCoreData(moviesFromBackend: [Movie]?) {
        // 0. Prepare incoming server side movies ID list and dictionary
        var moviesIdDict: [Int: Movie] = [:]
        var moviesIdList: [Int] = []
        
        guard let movies = moviesFromBackend, !movies.isEmpty else {
            return
        }
        
        for movie in movies {
            moviesIdDict[movie.id] = movie
        }
            
        moviesIdList = movies.map { $0.id }
        
        // 1. Get all the movies that match incoming server side movied ID
        // Find any existing movies in our local core data
        moviesFetchRequest.predicate = NSPredicate(format: "id IN %@", moviesIdList)

        // 2. Make a fetch request using predicate
        let managedObjectContext = persistentContainer.viewContext
           
        let moviesCDList = try? managedObjectContext.fetch(moviesFetchRequest)
        guard let moviesCDList = moviesCDList else {
            return
        }

      var moviesIdListInCD: [Int] = []
        
        // 3. Update all matching movies to have the same data
        for movieCD in moviesCDList {
            
//            managedObjectContext.delete(movieCD)
            
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
                let genreCD = GenreCD(context: managedObjectContext)
                genreCD.id = 1
                genreCD.title = "Comedy"
                
                let movieCD = MovieCD(context: managedObjectContext)
                movieCD.id = Int64(movie.id)
                movieCD.title = movie.title
                movieCD.overview = movie.overview
                movieCD.releaseDate = movie.releaseDate
                movieCD.imageUrlSuffix = movie.imageUrlSuffix
                movieCD.genre = genreCD
            }
        }
        
        // 5. Save changes
        try? managedObjectContext.save()
    }
    
    func updateAndAddMovieRatingServerDataToCoreData(movieRatingFromBackend: [MovieRating]?) {
        // 0. Prepare incoming server side movies ID list and dictionary
        var movieRatingsIdDict: [Int: MovieRating] = [:]
        var movieRatingsIdList: [Int] = []
        
        guard let movieRatings = movieRatingFromBackend, !movieRatings.isEmpty else {
            return
        }
        
        for movieRating in movieRatings {
            movieRatingsIdDict[movieRating.id] = movieRating
        }
            
        movieRatingsIdList = movieRatings.map { $0.id }
        
        // 1. Get all the movies that match incoming server side movied ID
        // Find any existing movies in our local core data
        movieRatingsFetchRequest.predicate = NSPredicate(format: "id IN %@", movieRatingsIdList)

        // 2. Make a fetch request using predicate
        let managedObjectContext = persistentContainer.viewContext
           
        let movieRatingsCDList = try? managedObjectContext.fetch(movieRatingsFetchRequest)
        guard let movieRatingsCDList = movieRatingsCDList else {
            return
        }

      var movieRatingsIdListInCD: [Int] = []
        
        // 3. Update all matching movies to have the same data
        for movieRatingCD in movieRatingsCDList {
            movieRatingsIdListInCD.append(Int(movieRatingCD.id))
            if let movieRating = movieRatingsIdDict[Int(movieRatingCD.id)] {
                movieRatingCD.setValue(movieRating.popularity, forKey: "popularity")
                movieRatingCD.setValue(movieRating.title, forKey: "title")
                movieRatingCD.setValue(movieRating.voteAverage, forKey: "voteAverage")
                movieRatingCD.setValue(movieRating.voteCount, forKey: "voteCount")
          }
            
        }
        
        // 4. Add new objects coming from the backend/server side
        for movieRating in movieRatings {
            if !movieRatingsIdListInCD.contains(movieRating.id) {
                let movieRatingCD = MovieRatingCD(context: managedObjectContext)
                movieRatingCD.id = Int64(movieRating.id)
                movieRatingCD.title = movieRating.title
                movieRatingCD.popularity = movieRating.popularity
                movieRatingCD.voteCount = Int64(movieRating.voteCount)
                movieRatingCD.voteAverage = movieRating.voteAverage
            }
        }
        
        // 5. Save changes
        try? managedObjectContext.save()
    }
    
    func fetchMoviesFromCoreData() -> [Movie] {
        let movieTitleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let releaseDateSortDescriptor = NSSortDescriptor(key: "releaseDate", ascending: true)
        moviesFetchRequest.sortDescriptors = [movieTitleSortDescriptor, releaseDateSortDescriptor]
        
        let moviesCDList = try? persistentContainer.viewContext.fetch(moviesFetchRequest)
        
        var convertedMovies: [Movie] = []
        guard let moviesCDList = moviesCDList else {
            return []
        }
        
        for movieCD in moviesCDList {
            let movie = Movie(id: Int(movieCD.id), title: movieCD.title ?? "", releaseDate: movieCD.releaseDate ?? "", imageUrlSuffix: movieCD.imageUrlSuffix ?? "", overview: movieCD.overview ?? "")
            convertedMovies.append(movie)
        }
        
        return convertedMovies
    }
    
    func fetchMovieRatingsFromCoreData() -> [MovieRating] {
        let movieRatingVoteCountSortDescriptor = NSSortDescriptor(key: "voteCount", ascending: true)
       
        movieRatingsFetchRequest.sortDescriptors = [movieRatingVoteCountSortDescriptor]
        
        let movieRatingsCDList = try? persistentContainer.viewContext.fetch(movieRatingsFetchRequest)
        
        var convertedMovieRatings: [MovieRating] = []
        guard let movieRatingsCDList = movieRatingsCDList else {
            return []
        }
        
        for movieRatingCD in movieRatingsCDList {
            let movieRating = MovieRating(id: Int(movieRatingCD.id), title: movieRatingCD.title ?? "", popularity: movieRatingCD.popularity, voteCount: Int(movieRatingCD.voteCount), voteAverage: movieRatingCD.voteAverage)
            convertedMovieRatings.append(movieRating)
        }
        
        return convertedMovieRatings
    }
  
}
