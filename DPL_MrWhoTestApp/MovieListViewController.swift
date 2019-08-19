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
                                UIPickerViewDelegate, UIPickerViewDataSource,
                                UITextFieldDelegate {

    @IBOutlet weak var movieTypePickerView: UIPickerView!
    @IBOutlet weak var movieListLoadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var minVoteTextField: UITextField!
    @IBOutlet weak var minVoteSlider: UISlider!
    @IBOutlet weak var movieCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(redrawMovieList), name: NSNotification.Name(rawValue: TMDbManager.NewMovieListNotification), object: nil)

        self.minVoteTextField.addTarget(self, action: #selector(updateVoteFilter), for: .editingChanged)

        self.movieListLoadingSpinner.startAnimating()
        TMDbManager.shared.getMovieList(.popular)

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"MovieListViewCell", for: indexPath) as! MovieListViewCell

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
        if let detailViewController: MovieDetailViewController = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            let movieIndex = TMDbManager.shared.filteredMovieList[indexPath.row]
            detailViewController.updateDetailMovieIndex(movieIndex)

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

        return "Error?"
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let listType = TMDbManager.MovieListType(rawValue: row) {
            self.movieListLoadingSpinner.startAnimating()
            TMDbManager.shared.getMovieList(listType)
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Clicking "GO" on the keyboard dismisses the keyboard.
        textField.resignFirstResponder()

        return true
    }

    // MARK: Text Field

    @objc func updateVoteFilter() {
        var voteFilter: CGFloat = 0.0

        if let filterString = self.minVoteTextField.text,
            let validFloat = Float(filterString) {
                voteFilter = CGFloat(validFloat)
        }

        self.minVoteSlider.value = Float(voteFilter)

        TMDbManager.shared.filterMovieList(vote: voteFilter)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Touching outside the text field dismisses the keyboard.
        self.view.endEditing(true)

        super.touchesBegan(touches, with: event)
    }

    // MARK: Notifications

    @objc func redrawMovieList() {
        DispatchQueue.main.async { [weak self] in
            self?.movieListLoadingSpinner.stopAnimating()
            self?.movieCollectionView.reloadData()
        }
    }

    // MARK: IBActions

    @IBAction func minVoteSliderChanged() {
        let voteFilter = self.minVoteSlider.value

        self.minVoteTextField.text = String(voteFilter)

        TMDbManager.shared.filterMovieList(vote: CGFloat(voteFilter))
    }
}

