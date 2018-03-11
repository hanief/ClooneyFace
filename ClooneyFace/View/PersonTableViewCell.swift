//
//  PersonTableViewCell.swift
//  ClooneyFace
//
//  Created by Hanief on 10/03/2018.
//  Copyright © 2018 Ruminant Ablutionist. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var faceView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    
    var webURL = ""
    var twitterAccount = ""
    var linkedInAccount = ""
    
    var delegate: PersonTableViewCellDelegate?
    
    @IBAction func webButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapWebButtonOnCell(self)
    }
    
    @IBAction func twitterButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapTwitterButtonOnCell(self)
    }
    
    @IBAction func linkedInButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapLinkedInButtonOnCell(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol PersonTableViewCellDelegate: class {
    func didTapWebButtonOnCell(_ cell: PersonTableViewCell)
    func didTapTwitterButtonOnCell(_ cell: PersonTableViewCell)
    func didTapLinkedInButtonOnCell(_ cell: PersonTableViewCell)
}
