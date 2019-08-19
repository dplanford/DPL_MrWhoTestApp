//
//  MovieDetailViewController.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//
//  A View Controller that displays details about a movie, from the TMDb online
//  database.
//

import UIKit

class MovieDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!

    var detailMovieIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let thisMovie = TMDbManager.shared.currentMovieList[self.detailMovieIndex]

        self.titleLabel.text = thisMovie[TMDbManager.tmdbTitle] as? String
    }
    
    public func updateDetailMovieIndex(_ val: Int) {
        self.detailMovieIndex = val

        let thisMovie = TMDbManager.shared.currentMovieList[self.detailMovieIndex]

        if let label = self.titleLabel {
            label.text = thisMovie[TMDbManager.tmdbTitle] as? String
        }

        self.view.layoutIfNeeded()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2 table items... poster & description.
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            // row 0 is the poster... make room for standard poster height half more than width.
            return tableView.bounds.width * 1.5
        }

        // row 1 is the description text field, fixed height.
        return 280.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisMovie = TMDbManager.shared.currentMovieList[self.detailMovieIndex]

        if indexPath.row == 0 {
            // poster cell.
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieDetailPosterCell.reuseID, for: indexPath) as! MovieDetailPosterCell

            if let posterPath = thisMovie["poster_path"] as? String {
                cell.poster.image = TMDbManager.shared.getMovieImage(fileName: posterPath)
            }

            return cell
        }

        // description cell... movie overview blurb, plus release date, votes, and original language.
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieDetailDescriptionCell.reuseID, for: indexPath) as! MovieDetailDescriptionCell

        var description = ""

        if let overview = thisMovie[TMDbManager.tmdbOverview] as? String {
            description += overview
        }

        description += "\n---------------------------------"

        if let releaseDate = thisMovie[TMDbManager.tmdbReleaseDate] as? String {
            description += "\nReleased \(releaseDate)"
        }

        if let voteAverage = thisMovie[TMDbManager.tmdbVoteAverage] as? CGFloat {
            description += "\nVote Average: \(voteAverage)"

            if let votes = thisMovie[TMDbManager.tmdbVoteCount] as? Int {
                description += " (\(votes) votes)"
            }
        }

        if let language = thisMovie[TMDbManager.tmdbOrigLanguage] as? String {
            description += "\nOriginal Language: \(language)"
        }

        cell.descriptionTextArea.text = description

        return cell
    }

    // MARK: IBActions

    @IBAction func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
