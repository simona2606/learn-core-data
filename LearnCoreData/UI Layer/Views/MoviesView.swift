//
//  MoviesView.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import SwiftUI
import Charts

struct MoviesView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    
    var body: some View {
        
        NavigationView {
            TabView {
                List {
                    Section(header: Text("Popular Movies")) {
                        ForEach(viewModel.movies) { movie in
                            NavigationLink(destination: MovieDetailsView(movie: movie)) {
                                MovieCardView(movie: movie)
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        do {
                            try await viewModel.getMovies()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .tabItem {
                    Label("Movies", systemImage: "popcorn.fill")
                }
                ScrollView {
                    Chart {
                        ForEach(viewModel.movieRatings.prefix(15)) { movie in
                            
                            RectangleMark(x: .value("Movies", movie.title), y: .value("Vote Average", movie.voteAverage), width: .ratio(0.6), height: 3)
                            
                            
                            BarMark(x: .value("Movies", movie.title),
                                    yStart: .value("Vote Min", movie.minVote()),
                                    yEnd: .value("Vote Max", movie.maxVote()))
                            .symbol(by: .value("Movie", movie.title))
                            .opacity(0.3)
                        }
                        .foregroundStyle(.gray.opacity(0.5))
                        
                        RuleMark(y: .value("Average", viewModel.getMovieRatingsVoteAverage()))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .annotation(position: .top, alignment: .leading) {
                                Text("Average \(viewModel.getMovieRatingsVoteAverage(), format: .number)")
                                    .font(.italic(.body)())
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                            }
                    }
                    .padding(.horizontal, 8)
                    .chartYScale(domain: 0...35)
                    .chartYAxis {
                        AxisMarks(preset: .extended, position: .leading)
                    }
                    
                    .chartPlotStyle(content: { plotArea in
                        plotArea
                            .frame(height: 500)
                            .lineLimit(3)
                            .background(.pink.opacity(0.1))
                            .border(.blue, width: 1)
                    })
                }
                .onAppear {
                    Task {
                        do {
                            try await viewModel.getMovieRating()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .padding(15)
                .tabItem {
                    Label("Rating", systemImage: "chart.bar")
                }
                
            }
            .navigationTitle("Movies")
        }
        
    }
}

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
            .environmentObject(MoviesViewModel())
    }
}
