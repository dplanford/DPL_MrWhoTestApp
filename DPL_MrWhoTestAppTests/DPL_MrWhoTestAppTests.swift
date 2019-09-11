//
//  DPL_MrWhoTestAppTests.swift
//  DPL_MrWhoTestAppTests
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//

import XCTest

@testable import DPL_MrWhoTestApp

class DPL_MrWhoTestAppTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetSimpleMovieListURL() {
        let movieListType = TMDbManager.MovieListType.upcoming

        let url = TMDbManager.shared.getMovieListURL(movieListType, searchText: nil, page: nil)

        // Check if return URL is non-null, and matches expectations.
        XCTAssertNotNil(url)
        if let validURL = url {
            XCTAssertEqual(validURL, URL(string: "\(TMDbManager.TMDbBaseURL)\(TMDbManager.MovieListType.upcoming.listTypeURL())\(TMDbManager.TMDbAPIAccessKey)"))
        }

        // Check if the TMDb Manager settings are correct for the current simple search.
        XCTAssertEqual(TMDbManager.shared.currentListType, movieListType)
        XCTAssertNil(TMDbManager.shared.currentSearchText)
        XCTAssertEqual(TMDbManager.shared.currentPage, 1)
    }

    func testGetMovieImageURL() {
        let url = TMDbManager.shared.getMovieImageURL(fileName: "starwars.jpg")

        XCTAssertNotNil(url)
        XCTAssertEqual(url, URL(string: "\(TMDbManager.TMDbBaseImageURL)starwars.jpg\(TMDbManager.TMDbAPIAccessKey)"))
    }
}
