//
//  RoundButton.swift
//  park.ly
//
//  Created by Jadson on 19/05/22.
//

import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        //MARK: Corner radius
        self.layer.cornerRadius = self.frame.height / 2
        
        //MARK: Shadow
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }

}
