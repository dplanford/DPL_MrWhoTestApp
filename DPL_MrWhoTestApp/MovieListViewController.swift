//
//  ViewController.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController,
                                UICollectionViewDelegate, UICollectionViewDataSource,
                                UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var movieTypePickerView: UIPickerView!
    @IBOutlet weak var movieListLoadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var minVoteTextField: UITextField!
    @IBOutlet weak var movieCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.movieListLoadingSpinner.startAnimating()
        TMDbManager.getMovieList(.popular)

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
            detailViewController.updateDetailMovieIndex(indexPath.row)
            self.present(detailViewController, animated: true, completion: nil)
        }
    }

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TMDbManager.MovieListType.count()
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let listType = TMDbManager.MovieListType(rawValue: row) {
            return listType.listTypeString()
        }

        return "Error"
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let listType = TMDbManager.MovieListType(rawValue: row) {
            self.movieListLoadingSpinner.startAnimating()
            TMDbManager.getMovieList(listType)
        }
    }

    // MARK: Local notifications

    @objc func redrawMovieList() {
        DispatchQueue.main.async { [weak self] in
            self?.movieListLoadingSpinner.stopAnimating()
            self?.movieCollectionView.reloadData()
        }
    }
}

