//
//  Account.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation

class Account {
    static let shared = Account()
    
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    
    var balance: Double = 0
    var interestRate: Double = 6
    
    var isPlaidConnected: Bool = false
}
