//
//  BLETableViewCell.swift
//  BLEApp
//
//  Created by antonio on 2025/9/27.
//

import UIKit

class BLETableViewCell: UITableViewCell {
    
    static let identifier = "BLETableViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var advLabel: UILabel!
    
    var connectButtonClickClosure: (() -> Void)?
    
    @IBAction func buttonClick(_ sender: Any) {
        if let closure = connectButtonClickClosure {
            closure()
        }
    }
}
