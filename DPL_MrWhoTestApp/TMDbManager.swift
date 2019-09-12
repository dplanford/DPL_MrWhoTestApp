//
//  TMDbManager.swift
//  DPL_MrWhoTestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//
//  This class manages online access to the TMDb database.
//

import Foundation
import UIKit

class TMDbManager {

    // Access for TMDbManager is through a singleton.
    public static let shared = TMDbManager()

    public static let NewMovieListNotification = "DPLMrWho-NewMovieListNotification"

    // TMDb keys.
    public static let tmdbResults = "results"
    public static let tmdbTotalPages = "total_pages"
    public static let tmdbTitle = "title"
    public static let tmdbPosterPath = "poster_path"
    public static let tmdbOverview = "overview"
    public static let tmdbReleaseDate = "release_date"
    public static let tmdbVoteAverage = "vote_average"
    public static let tmdbVoteCount = "vote_count"
    public static let tmdbOrigLanguage = "original_language"
    public static let tmdbSearchQuery = "&query="
    public static let tmdbSearchPage = "&page="

    public enum MovieListType: Int {
        // First several define the main screen's picker view.
        case popular = 0
        case upcoming = 1
        case nowPlaying = 2
        case topRated = 3

        static func pickerListCount() -> Int {
            return 4
        }

        // Other types of movie lists.
        case search = 10

        // Title string for this movie list type.
        func listTypeString() -> String {
            switch self {
            case .popular:      return "Popular"
            case .upcoming:     return "Upcoming"
            case .nowPlaying:   return "Now Playing"
            case .topRated:     return "Top Rated"
            default:            return "Search"
            }
        }

        // TMDb URL string for this movie list type.
        func listTypeURL() -> String {
            switch self {
            case .popular:      return "movie/popular"
            case .upcoming:     return "movie/upcoming"
            case .nowPlaying:   return "movie/now_playing"
            case .topRated:     return "movie/top_rated"
            case .search:       return "search/movie"
            }
        }
    }

    public var currentMovieList: [[String: Any]] = []   // The currently loaded movie list.
    public var filteredMovieList: [Int] = []    // The currently filtered and displayed subset of the loaded movie list.

    public var currentListType = TMDbManager.MovieListType.popular
    public var totalPages = 1
    public var currentPage = 1

    internal static let TMDbBaseURL = "https://api.themoviedb.org/3/"
    internal static let TMDbBaseImageURL = "https://image.tmdb.org/t/p/w500/"
    internal static let TMDbAPIAccessKey = "?api_key=a868cc859b204425655c020f8b7eb2ab"

    internal var currentMovieImageCache: [String: UIImage] = [:]
    internal var currentSearchText: String? = nil
    internal var voteAverageFilter: CGFloat = 0.0

    public func getMovieList(_ listType: TMDbManager.MovieListType, searchText: String?, page: Int?) {
        guard let url = self.getMovieListURL(listType, searchText: searchText, page: page) else {
            print("Error - Null movie list URL returned.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60.0

        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let task = urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // Handle the Async response to the TMDb request.
            self.processMovieListResponse(data: data, error: error)

            TMDbManager.shared.filterMovieList(voteAverage: self.voteAverageFilter)
        }

        task.resume()
    }

    public func getSimpleMovieList(_ listType: TMDbManager.MovieListType) {
        self.getMovieList(listType, searchText: nil, page: nil)
    }

    public func getMovieListPreviousPage() {
        guard self.currentPage > 1 else {
            // Already on the first page, no previous page available.
            return
        }

        self.currentPage -= 1

        self.getMovieList(self.currentListType, searchText: self.currentSearchText, page: self.currentPage)
    }

    public func getMovieListNextPage() {
        guard self.currentPage < self.totalPages else {
            // Already on the last page, no next page available.
            return
        }

        self.currentPage += 1

        self.getMovieList(self.currentListType, searchText: self.currentSearchText, page: self.currentPage)
    }

    public func getMovieImage(fileName: String) -> UIImage? {
        if let image = self.currentMovieImageCache[fileName] {
            // return cached image.
            return image
        }

        guard let url = self.getMovieImageURL(fileName: fileName) else {
            print("Error - image URL string is invalid")
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

    // TODO: Add unit tests for this function, using pre-built test data?
    public func filterMovieList(voteAverage: CGFloat) {
        self.voteAverageFilter = voteAverage
        self.filteredMovieList = []

        for i in 0 ..< self.currentMovieList.count {
            let thisMovie = self.currentMovieList[i]

            if let voteAverage = thisMovie[TMDbManager.tmdbVoteAverage] as? CGFloat {
                if voteAverage >= self.voteAverageFilter {
                    // This movie's vote average is equal or greater than the filter setting... add it.
                    self.filteredMovieList.append(i)
                }
            }
        }

        // Notify the app that a new movie list is available.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
    }

    // MARK: Private functions.

    internal func getMovieListURL(_ listType: TMDbManager.MovieListType, searchText: String?, page: Int?) -> URL? {
        self.currentListType = listType

        var urlString = "\(TMDbManager.TMDbBaseURL)\(listType.listTypeURL())\(TMDbManager.TMDbAPIAccessKey)"

        if let validSearchText = searchText {
            let spaceAdjustedText = validSearchText.replacingOccurrences(of: " ", with: "%20")
            urlString += "\(TMDbManager.tmdbSearchQuery)\(spaceAdjustedText)"

            self.currentSearchText = validSearchText
        } else {
            self.currentSearchText = nil
        }

        if let validPage = page {
            urlString += "\(TMDbManager.tmdbSearchPage)\(validPage)"

            self.currentPage = validPage
        } else {
            self.currentPage = 1
        }

        //print("URL = \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Error - URL string is invalid")
            return nil
        }

        return url
    }

    internal func getMovieImageURL(fileName: String) -> URL? {
        let urlString = "\(TMDbManager.TMDbBaseImageURL)\(fileName)\(TMDbManager.TMDbAPIAccessKey)"

        //print("Image URL = \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Error - URL string is invalid")
            return nil
        }

        return url
    }

    // TODO: Add unit tests for this function, using pre-built test data?
    internal func processMovieListResponse(data: Data?, error: Error?) {
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

        //print(content)

        guard let movieArray = content[TMDbManager.tmdbResults] as? [[String: Any]] else {
            print("Error - response dictionary results does not parse to an array of dictionaries")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
            return
        }

        if let validTotalPages = content[TMDbManager.tmdbTotalPages] as? Int {
            self.totalPages = validTotalPages
        } else {
            self.totalPages = 1
        }

        self.currentMovieList = movieArray
        
        //print(self.currentMovieList)
    }
}
