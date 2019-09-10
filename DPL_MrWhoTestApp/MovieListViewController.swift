//
//  MovieListViewController.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//
//  A View Controller for displaying a list of movies from the TMDb online database,
//  as well as a way to pick which type of movie list, and filter by vote average.
//  Clicking on a movie goes to that movie's detail view (an instance of the class
//  MovieDetailViewController)
//  This is the root view of this app.
//

import UIKit

class MovieListViewController: UIViewController,
                                UICollectionViewDelegate, UICollectionViewDataSource,
                                UIPickerViewDelegate, UIPickerViewDataSource,
                                UITextFieldDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var movieTypePickerView: UIPickerView!
    @IBOutlet weak var movieListLoadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var minVoteTextField: UITextField!
    @IBOutlet weak var minVoteSlider: UISlider!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var previousPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var pageCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.previousPageButton.layer.cornerRadius = 20.0
        self.nextPageButton.layer.cornerRadius = 20.0

        NotificationCenter.default.addObserver(self, selector: #selector(redrawMovieList), name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil)

        self.minVoteTextField.addTarget(self, action: #selector(updateVoteFilter), for: .editingChanged)

        self.movieListLoadingSpinner.startAnimating()
        TMDbManager.shared.getSimpleMovieList(.popular)

        self.minVoteSliderChanged()
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TMDbManager.shared.filteredMovieList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListViewCell.reuseID, for: indexPath) as! MovieListViewCell

        let movieIndex = TMDbManager.shared.filteredMovieList[indexPath.row]
        let thisMovie = TMDbManager.shared.currentMovieList[movieIndex]

        cell.label.text = thisMovie[TMDbManager.tmdbTitle] as? String

        if let posterPath = thisMovie[TMDbManager.tmdbPosterPath] as? String {
            cell.poster.image = TMDbManager.shared.getMovieImage(fileName: posterPath)
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailViewController = storyboard.instantiateViewController(withIdentifier: MovieDetailViewController.storyboardID) as? MovieDetailViewController {
            let movieIndex = TMDbManager.shared.filteredMovieList[indexPath.row]
            detailViewController.updateDetailMovieIndex(movieIndex)

            self.present(detailViewController, animated: true, completion: nil)
        }
    }

    // MARK: UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Dismiss the search keyboard.
        searchBar.resignFirstResponder()

        guard let searchText = searchBar.text, searchText.count > 0 else {
            // Error... do default search (for Totoro).
            self.searchTotoro()
            return
        }

        TMDbManager.shared.getMovieList(TMDbManager.MovieListType.search, searchText: searchText, page: nil)
    }

    // MARK: UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TMDbManager.MovieListType.pickerListCount()
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let listType = TMDbManager.MovieListType(rawValue: row) {
            return listType.listTypeString()
        }

        return "Error - Outside Movie List Types!"
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let listType = TMDbManager.MovieListType(rawValue: row) {
            self.movieListLoadingSpinner.startAnimating()
            TMDbManager.shared.getSimpleMovieList(listType)
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Clicking "GO" on the vote average keyboard dismisses the keyboard.
        textField.resignFirstResponder()

        return true
    }

    // MARK: Vote Average Text Field

    @objc func updateVoteFilter() {
        var voteFilter: CGFloat = 0.0

        if let filterString = self.minVoteTextField.text,
            let validFloat = Float(filterString) {
                voteFilter = CGFloat(validFloat)
        }

        self.minVoteSlider.value = Float(voteFilter)

        TMDbManager.shared.filterMovieList(voteAverage: voteFilter)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Touching outside the vote average filter text field dismisses the keyboard.
        self.view.endEditing(true)

        super.touchesBegan(touches, with: event)
    }

    // MARK: Notifications

    @objc func redrawMovieList() {
        DispatchQueue.main.async { [weak self] in
            self?.movieListLoadingSpinner.stopAnimating()
            self?.movieCollectionView.reloadData()

            self?.previousPageButton.isHidden = TMDbManager.shared.currentPage <= 1
            self?.nextPageButton.isHidden = TMDbManager.shared.currentPage >= TMDbManager.shared.totalPages

            self?.pageCountLabel?.text = "Page \(TMDbManager.shared.currentPage) of \(TMDbManager.shared.totalPages)"
        }
    }

    // MARK: IBActions

    @IBAction func previousPageClicked() {
        TMDbManager.shared.getMovieListPreviousPage()
    }

    @IBAction func nextPageClicked() {
        TMDbManager.shared.getMovieListNextPage()
    }

    @IBAction func minVoteSliderChanged() {
        let voteFilter = self.minVoteSlider.value

        self.minVoteTextField.text = String(voteFilter)

        TMDbManager.shared.filterMovieList(voteAverage: CGFloat(voteFilter))
    }

    @IBAction func searchTotoro() {
        TMDbManager.shared.getMovieList(TMDbManager.MovieListType.search, searchText: "totoro", page: nil)
    }
}

