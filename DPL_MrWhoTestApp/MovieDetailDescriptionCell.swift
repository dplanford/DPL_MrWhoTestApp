//
//  MovieDetailDescriptionCell.swift
//  DPL_MrWhoTestApp
//
//  Created by Douglas Lanford on 8/18/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//
//  A UITableViewCell subclass that displays a text area with the movie's text details.
//

import UIKit

class MovieDetailDescriptionCell: UITableViewCell {

    static let reuseID = "MovieDetailDescriptionCell"

    @IBOutlet public weak var descriptionTextArea: UITextView!
}
