//
//  ViewController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit
import Bitski
import Web3
import PromiseKit

let BitskiClientID = "6e244309-4f5f-44cf-a72f-bc3e1c19ad52"
let BitskiRedirectURL = "io.zerion.defy://application/callback"

class ViewController: UIViewController {
    
    var web3: Web3?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Replace redirect URL with an url scheme that will hit your native app
        Bitski.shared = Bitski(clientID: BitskiClientID,
                               redirectURL: URL(string: BitskiRedirectURL)!)
        
        Bitski.shared?.signIn() { error in
            // Once signed in, get an instance of Web3
            self.web3 = Bitski.shared?.getWeb3()
            self.getAccount()
        }
    }

    func getAccount() {
        
        if let web3 = self.web3 {
            do {
                let compound = try CompoudService(provider: web3)
                
                firstly {
                    web3.eth.accounts().firstValue
                }.done { account in
                    print(account.hex(eip55: true))
                    
                    compound.getAvailableSupply(userAddress: account).done { balance in
                        print("DAI Balance")
                        print(balance)
                    }.catch { error in
                        print("error")
                        print(error)
                    }
                }
            } catch { error
                print(error)
            }
           
        }
        
    }
}

