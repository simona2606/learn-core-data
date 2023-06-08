//
//  MovieDetailsView.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import SwiftUI

struct MovieDetailsView: View {
    var movie: Movie
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    let url = URL(string: movie.getLargeImageUrl())
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .frame(width: 350, height: 450, alignment: .center)
                    } placeholder: {
                        Image("logo")
                            .resizable()
                            .frame(width: 250, height: 250)
                    }
                    Spacer()
                }
            
                Text("Released: \(movie.releaseDate)")
                    .font(.italic(.body)())
                    .padding(.horizontal, 8)
                Spacer()
                Text(movie.overview)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
            }
            .accessibilityLabel("Movie Details")
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.blue)
        .padding()
    }
}

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(movie: Movie(id: 1, title: "Terminator 2", releaseDate: "1997-10-01", imageUrlSuffix: "/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg", overview: "Terminator T-100 and the rest of the crew fight for the future of humanity"))
    }
}
