//
//  EgnytePickerTableViewCell.swift
//  SampleApp
//
//  Created by Adam Kędzia on 22.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit

@objc protocol PickerCellDelegate: class {
    func didTapActionsButton(cell: UITableViewCell) -> Void
}

class EgnytePickerTableViewCell: UITableViewCell {
    @IBOutlet weak var lastModified: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabelConstraint: NSLayoutConstraint!
    weak var delegate: PickerCellDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.contentView.backgroundColor = EgnyteTheme.cellBackground
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.contentView.backgroundColor = highlighted ? EgnyteTheme.cellHighlight : EgnyteTheme.cellBackground
    }
    
    func populateWith(viewModel: EgnytePickerCellViewModel) {
        self.lastModified.text = viewModel.lastModified
        self.name.text = viewModel.itemName
        self.iconLabel.text = viewModel.mimeIcon.iconLabel
        self.iconImage.image = viewModel.mimeIcon.iconImage
        
        if self.lastModified.text == nil {
            self.nameLabelConstraint.constant = 9
        }else {
            self.nameLabelConstraint.constant = 0
        }
    }
    
    @IBAction func selecteditemActions(_ sender: UIButton) {
        self.delegate?.didTapActionsButton(cell: self)
    }
}
