//
//  DetailViewController.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!

    var detailMovieIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let thisMovie = TMDbManager.shared.currentMovieList[self.detailMovieIndex]

        self.titleLabel.text = thisMovie["title"] as? String
    }
    
    public func updateDetailMovieIndex(_ val: Int) {
        self.detailMovieIndex = val

        let thisMovie = TMDbManager.shared.currentMovieList[self.detailMovieIndex]

        if let label = self.titleLabel {
            label.text = thisMovie["title"] as? String
        }

        self.view.layoutIfNeeded()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.bounds.width * 1.5
        }

        return 200.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisMovie = TMDbManager.shared.currentMovieList[self.detailMovieIndex]

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieDetailPosterCell.reuseID, for: indexPath) as! MovieDetailPosterCell

            if let posterPath = thisMovie["poster_path"] as? String {
                cell.poster.image = TMDbManager.shared.getMovieImage(fileName: posterPath)
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: MovieDetailDescriptionCell.reuseID, for: indexPath) as! MovieDetailDescriptionCell

        var description = ""

        if let overview = thisMovie["overview"] as? String {
            description += overview
        }

        description += "\n-----------------------------"

        if let releaseDate = thisMovie["release_date"] as? String {
            description += "\nReleased \(releaseDate)"
        }

        if let voteAverage = thisMovie["vote_average"] as? CGFloat {
            description += "\nVote Average: \(voteAverage)"

            if let votes = thisMovie["vote_count"] as? Int {
                description += " (\(votes) votes)"
            }
        }

        if let language = thisMovie["original_language"] as? String {
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
