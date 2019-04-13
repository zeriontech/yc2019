//
//  WyreService.swift
//  defy
//
//  Created by Vadim Koleoshkin on 13/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import PromiseKit

protocol IWyreService {
    
    func getSession(address: String) -> Promise<String>
    
}

