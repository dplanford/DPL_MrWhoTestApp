//
//  ViewController.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    static let CellAspectRatio: CGFloat = 1.5

    @IBOutlet weak var movieCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        TMDbManager.getMovieList()

        NotificationCenter.default.addObserver(self, selector: #selector(redrawMovieList), name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TMDbManager.currentMovieList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"MovieListViewCell", for: indexPath) as! MovieListViewCell

        let thisMovie = TMDbManager.currentMovieList[indexPath.row]

        cell.label.text = thisMovie["title"] as? String

        if let posterPath = thisMovie["poster_path"] as? String {
            cell.poster.image = TMDbManager.getMovieImage(fileName: posterPath)
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailViewController: MovieDetailViewController = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            detailViewController.updateDetailValue(indexPath.row)
            self.present(detailViewController, animated: true, completion: nil)
        }
    }

    // MARK: Notifications

    @objc func redrawMovieList() {
        DispatchQueue.main.async { [weak self] in
            self?.movieCollectionView.reloadData()
        }
    }
}

