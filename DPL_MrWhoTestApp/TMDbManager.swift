//
//  TMDbManager.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//

import Foundation
import UIKit

class TMDbManager {

    public static let shared = TMDbManager()

    public static let NewMovieListNotification = "DPLMrWho-NewMovieListNotification"

    // TMDb keys.
    public static let tmdbTitle = "title"
    public static let tmdbPosterPath = "poster_path"
    public static let tmdbOverview = "overview"
    public static let tmdbReleaseDate = "release_date"
    public static let tmdbVoteAverage = "vote_average"
    public static let tmdbVoteCount = "vote_count"
    public static let tmdbOrigLanguage = "original_language"

    public enum MovieListType: Int {
        case popular = 0
        case upcoming
        case nowPlaying
        case topRated

        static func count() -> Int {
            return 4
        }

        func listTypeString() -> String {
            switch self {
            case .popular:      return "Popular"
            case .upcoming:     return "Upcoming"
            case .nowPlaying:   return "Now Playing"
            case .topRated:     return "Top Rated"
            }
        }

        func listTypeURL() -> String {
            switch self {
            case .popular:      return "movie/popular"
            case .upcoming:     return "movie/upcoming"
            case .nowPlaying:   return "movie/now_playing"
            case .topRated:     return "movie/top_rated"
            }
        }
    }

    public var currentMovieList: [[String: Any]] = []
    public var filteredMovieList: [Int] = []

    private static let BaseURL = "https://api.themoviedb.org/3/"
    private static let BaseImageURL = "https://image.tmdb.org/t/p/w500/"
    private static let APIKey = "?api_key=a868cc859b204425655c020f8b7eb2ab"

    private var currentMovieImageCache: [String: UIImage] = [:]
    private var voteAverageFilter: CGFloat = 7.0

    public func getMovieList(_ listType: TMDbManager.MovieListType) {
        let urlString = "\(TMDbManager.BaseURL)\(listType.listTypeURL())\(TMDbManager.APIKey)"
        //print("URL = \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Error - URL string is invalid")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60.0

        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let task = urlSession.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            self.currentMovieList = []
            self.currentMovieImageCache = [:] // reset image cache for the new movie list

            if error != nil {
                print("Response Error: \(error.debugDescription)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
                return
            }

            guard let validData = data else {
                print("Error - response data is empty")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
                return
            }

            guard let jsonData = try? JSONSerialization.jsonObject(with: validData, options: .allowFragments) else {
                print("Error - response data could not be parsed to JSON")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
                return
            }

            guard let content = jsonData as? [String: Any] else {
                print("Error - response JSON does not parse to a dictionary")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
                return
            }

            guard let movieArray = content["results"] as? [[String: Any]] else {
                print("Error - response dictionary results does not parse to an array of dictionaries")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
               return
            }

            self.currentMovieList = movieArray
            //print(self.currentMovieList)

            TMDbManager.shared.filterMovieList(vote: self.voteAverageFilter)
        }

        task.resume()
    }

    public func getMovieImage(fileName: String) -> UIImage? {
        if let image = self.currentMovieImageCache[fileName] {
            // return cached image.
            return image
        }

        // get a new image from the TMDb server
        let urlString = "\(TMDbManager.BaseImageURL)\(fileName)\(TMDbManager.APIKey)"
        //print("Image URL = \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Error - URL string is invalid")
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Error - no image data returned")
            return nil
        }

        let image = UIImage(data: data)
        self.currentMovieImageCache[fileName] = image    // cache the image, keyed by filename.

        return image
    }

    public func filterMovieList(vote: CGFloat) {
        self.voteAverageFilter = vote
        self.filteredMovieList = []

        for i in 0 ..< self.currentMovieList.count {
            let thisMovie = self.currentMovieList[i]

            if let voteAverage = thisMovie[TMDbManager.tmdbVoteAverage] as? CGFloat {
                if voteAverage >= self.voteAverageFilter {
                    self.filteredMovieList.append(i)
                }
            }
        }

        // Notify the app that a new movie list is available.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
    }
}
