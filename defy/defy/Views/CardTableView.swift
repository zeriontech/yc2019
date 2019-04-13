//
//  CardTableView.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/13/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit

class CardTableView: UITableViewCell, ViewReusable, NibLoadable {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var interestRate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setBalance(balance: Double) {
        if balance == 0 {
            self.balanceLabel.text = "Top-up your account"
        } else {
            self.balanceLabel.text = "$\(balance.rounded(toPlaces: 2))"
        }
    }
}

extension Double {
    func formatQuantities() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 5
        formatter.maximumFractionDigits = 2
        
        return String(formatter.string(from: number) ?? "")
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}
