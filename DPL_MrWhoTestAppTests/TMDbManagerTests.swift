//
//  DPL_MrWhoTestAppTests.swift
//  DPL_MrWhoTestAppTests
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//

import XCTest

@testable import DPL_MrWhoTestApp

class TMDbManagerTests: XCTestCase {

    func testGetSimpleMovieListURL() {
        let movieListType = TMDbManager.MovieListType.upcoming

        let url = TMDbManager.shared.getMovieListURL(movieListType, searchText: nil, page: nil)

        // Check if return URL is non-null, and matches expectations.
        XCTAssertNotNil(url)
        if let validURL = url {
            XCTAssertEqual(validURL, URL(string: "\(TMDbManager.TMDbBaseURL)\(movieListType.listTypeURL())\(TMDbManager.TMDbAPIAccessKey)"))
        }

        // Check if the TMDb Manager settings are correct for the current simple search.
        XCTAssertEqual(TMDbManager.shared.currentListType, movieListType)
        XCTAssertNil(TMDbManager.shared.currentSearchText)
        XCTAssertEqual(TMDbManager.shared.currentPage, 1)
    }

    func testGetMovieListURLWithSearchNilPage() {
        let movieListType = TMDbManager.MovieListType.popular
        let searchText = "Die Hard"
        let searchTextForURL = searchText.replacingOccurrences(of: " ", with: "%20")

        let url = TMDbManager.shared.getMovieListURL(movieListType, searchText: searchText, page: nil)

        // Check if return URL is non-null, and matches expectations.
        XCTAssertNotNil(url)
        if let validURL = url {
            XCTAssertEqual(validURL, URL(string: "\(TMDbManager.TMDbBaseURL)\(movieListType.listTypeURL())\(TMDbManager.TMDbAPIAccessKey)\(TMDbManager.tmdbSearchQuery)\(searchTextForURL)"))
        }

        // Check if the TMDb Manager settings are correct for the current search.
        XCTAssertEqual(TMDbManager.shared.currentListType, movieListType)
        XCTAssertEqual(TMDbManager.shared.currentSearchText, searchText)
        XCTAssertEqual(TMDbManager.shared.currentPage, 1)
    }

    func testGetMovieListURLWithPageNilSearch() {
        let movieListType = TMDbManager.MovieListType.topRated
        let page = 5

        let url = TMDbManager.shared.getMovieListURL(movieListType, searchText: nil, page: page)

        // Check if return URL is non-null, and matches expectations.
        XCTAssertNotNil(url)
        if let validURL = url {
            XCTAssertEqual(validURL, URL(string: "\(TMDbManager.TMDbBaseURL)\(movieListType.listTypeURL())\(TMDbManager.TMDbAPIAccessKey)\(TMDbManager.tmdbSearchPage)\(page)"))
        }

        // Check if the TMDb Manager settings are correct for the current search.
        XCTAssertEqual(TMDbManager.shared.currentListType, movieListType)
        XCTAssertEqual(TMDbManager.shared.currentSearchText, nil)
        XCTAssertEqual(TMDbManager.shared.currentPage, page)
    }

    func testGetMovieListURLWithSearchAndPage() {
        let movieListType = TMDbManager.MovieListType.popular
        let searchText = "Totoro"
        let page = 3

        let url = TMDbManager.shared.getMovieListURL(movieListType, searchText: searchText, page: page)

        // Check if return URL is non-null, and matches expectations.
        XCTAssertNotNil(url)
        if let validURL = url {
            XCTAssertEqual(validURL, URL(string: "\(TMDbManager.TMDbBaseURL)\(movieListType.listTypeURL())\(TMDbManager.TMDbAPIAccessKey)\(TMDbManager.tmdbSearchQuery)\(searchText)\(TMDbManager.tmdbSearchPage)\(page)"))
        }

        // Check if the TMDb Manager settings are correct for the current search.
        XCTAssertEqual(TMDbManager.shared.currentListType, movieListType)
        XCTAssertEqual(TMDbManager.shared.currentSearchText, searchText)
        XCTAssertEqual(TMDbManager.shared.currentPage, page)
    }
    
    func testGetMovieImageURL() {
        let imageName = "starwars.jpg"

        let url = TMDbManager.shared.getMovieImageURL(fileName: imageName)

        XCTAssertNotNil(url)
        XCTAssertEqual(url, URL(string: "\(TMDbManager.TMDbBaseImageURL)\(imageName)\(TMDbManager.TMDbAPIAccessKey)"))
    }
}
