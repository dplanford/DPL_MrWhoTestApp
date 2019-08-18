//
//  DetailViewController.swift
//  DPL-TMDb-TestApp
//
//  Created by Douglas Lanford on 8/17/19.
//  Copyright © 2019 Douglas Lanford. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var poster: UIImageView!

    var detailValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.label.text = String(self.detailValue)

        self.poster.image = TMDbManager.getMovieImage(fileName: "kqjL17yufvn9OVLyXYpvtyrFfak.jpg")
    }
    
    public func updateDetailValue(_ val: Int) {
        self.detailValue = val
        self.view.layoutIfNeeded()
    }

    @IBAction func backButtonTapped() {
        // TEMP!!! For testing TMDbManager
        TMDbManager.getMovieList()

        self.dismiss(animated: true, completion: nil)
    }
}
