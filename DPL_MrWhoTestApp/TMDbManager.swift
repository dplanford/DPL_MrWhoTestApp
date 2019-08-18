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

    private static let BaseURL = "https://api.themoviedb.org/3/"
    private static let BaseImageURL = "https://image.tmdb.org/t/p/w500/"
    private static let MoviesPopular = "movie/popular"
    private static let APIKey = "?api_key=a868cc859b204425655c020f8b7eb2ab"

    public static let NewMovieListNotification = "DPLMrWho-NewMovieListNotification"

    public static var currentMovieList: [[String: Any]] = []

    public static func getMovieList() {
        let urlString = "\(TMDbManager.BaseURL)\(TMDbManager.MoviesPopular)\(TMDbManager.APIKey)"
        print("URL = \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Error - URL string is invalid")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60.0

        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let task = urlSession.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            if error != nil {
                print("Response Error: \(error.debugDescription)")
                return
            }

            guard let validData = data else {
                print("Error - response data is empty")
                return
            }

            guard let jsonData = try? JSONSerialization.jsonObject(with: validData, options: .allowFragments) else {
                print("Error - response data could not be parsed to JSON")
                return
            }

            guard let content = jsonData as? [String: Any] else {
                print("Error - response JSON does not parse to a dictionary")
                return
            }

            guard let movieArray = content["results"] as? [[String: Any]] else {
                print("Error - response dictionary results does not parse to an array of dictionaries")
                return
            }

            self.currentMovieList = movieArray

            print(self.currentMovieList)

            //??? NotificationCenter.default.post(name: TMDbManager.NewMovieListNotification, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil, userInfo: nil)
        }

        task.resume()
    }

    public static func getMovieImage(fileName: String) -> UIImage? {
        let urlString = "\(TMDbManager.BaseImageURL)\(fileName)\(TMDbManager.APIKey)"
        print("Image URL = \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Error - URL string is invalid")
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Error - no image data returned")
            return nil
        }

        return UIImage(data: data)
    }
}
