//
//  MovieListViewCell.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//
//  A custom UICollectionViewCell subclass that displays a name and image for a movie.
//

import UIKit

class MovieListViewCell: UICollectionViewCell {

    static let reuseID = "MovieListViewCell"

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var poster: UIImageView!
}
