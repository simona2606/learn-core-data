//
//  MovieCardView.swift
//  LearnCoreData
//
//  Created by Simona Ettari on 06/06/23.
//

import Foundation
import SwiftUI

struct MovieCardView: View {
    var movie: Movie
    
    var body: some View {
        VStack {
            HStack {
                Text(movie.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
                let url = URL(string: movie.getThumbnailImageUrl())
                AsyncImage(url: url) { image in
                    image.scaledToFit()
                } placeholder: {
                    Image("logo")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            HStack {
                Text(movie.releaseDate)
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
            }
        }
        .padding()
    }
}

struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCardView(movie: Movie(id: 1, title: "Terminator 2", releaseDate: "1997-10-01", imageUrlSuffix: "/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg", overview: "Terminator T-100 and the rest of the crew fight for the future of humanity"))
    }
}
