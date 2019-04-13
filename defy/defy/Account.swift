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
    
}
