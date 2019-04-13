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
                let web3swift = Web3(rpcURL: "https://eth-mainnet.alchemyapi.io/jsonrpc/ETi2ntZoWxd6nTI1qE13Q4I1eLB8AMDl")
                
                let privateKey = try EthereumPrivateKey(hexPrivateKey: "PUT KEY HERE")
                
                print("Account 2")
                print(privateKey.address.hex(eip55: true))
                
                let compound = try CompoudService(provider: web3swift)
                
                firstly {
                    web3.eth.accounts().firstValue
                }.done { account in
                    print(account.hex(eip55: true))
                    let account2 = privateKey.address
                    compound.getAvailableSupply(userAddress: account2).done { balance in
                        print("DAI Balance")
                        print(balance)
                    }.catch { error in
                        print("DAI error")
                        print(error)
                    }
                    
                    compound.getSupplied(userAddress: account2).done { balance in
                        print("Compound Balance")
                        print(balance)
                    }.catch { error in
                        print("Compound error")
                        print(error)
                    }
                    
                    compound.supplyingIsApproved(
                        userAddress: account2,
                        supply: Decimal(10000)
                    ).done { balance in
                        print("Compound Allowance Available")
                        print(balance)
                    }.catch { error in
                        print("Compound allowance error")
                        print(error)
                    }
                    //Approve
//                    try compound.approveSupplying(
//                        userAddress: account,
//                        supply: 10000
//                    ).done { txHash in
//                        print("TX hash")
//                        print(txHash.hex())
//                    }
                    
                }
            } catch { error
                print(error)
            }
           
        }
        
    }
}

