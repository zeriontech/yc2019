//
//  TransactionCellView.swift
//  defy
//
//  Created by Vadim Koleoshkin on 13/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation
import UIKit

class TransactionViewCell: UITableViewCell, ViewReusable, NibLoadable {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUp(hash: String, sum: Decimal) -> Void {
        self.amount.text = "$\(sum)"
        self.descriptionText.text = "Deposit"
        self.imageView?.image = "🏦".image()
    }
    
}
