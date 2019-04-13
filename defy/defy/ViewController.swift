//
//  ViewController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit
//import Bitski
//import Web3
import PromiseKit
import CryptoSwift
import Web3Swift
import AwaitKit

let BitskiClientID = "6e244309-4f5f-44cf-a72f-bc3e1c19ad52"
let BitskiRedirectURL = "io.zerion.defy://application/callback"

class ViewController: UIViewController {
    
    //var web3: Web3?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAccount()
        // Do any additional setup after loading the view.
        
        // Replace redirect URL with an url scheme that will hit your native app
//        Bitski.shared = Bitski(clientID: BitskiClientID,
//                               redirectURL: URL(string: BitskiRedirectURL)!)
//
//        Bitski.shared?.signIn() { error in
//            // Once signed in, get an instance of Web3
//            self.web3 = Bitski.shared?.getWeb3()
//            self.getAccount()
//        }
    }

    func getAccount() {
        
        do {
            
            let privateKey = EthPrivateKey(
                hex: "YOUR_PRIVATE_KEY"
            )
            
            let address = EthAddress(hex: try privateKey.address().value().toHexString())
            var addressHex = try address.value().toHexString()
            addressHex = "0x"+addressHex
            
            let message = "EM3AMPYQZ4"
            
            print(try EthereumUtils.shared.singMessage(message: message, signer: privateKey))
            
            let network = AlchemyNetwork(
                chain: "mainnet", apiKey: "ETi2ntZoWxd6nTI1qE13Q4I1eLB8AMDl"
            )
            
            let savingsService = SavingsService(network: network)
            
            let account = address
            savingsService.getAvailableSupply(userAddress: account).done { balance in
                print("DAI Balance")
                print(balance)
            }.catch { error in
                print("DAI error")
                print(error)
            }
            
            savingsService.getSupplied(userAddress: account).done { balance in
                print("Compound Balance")
                print(balance)
            }.catch { error in
                print("Compound error")
                print(error)
            }
            
            savingsService.supplyingIsApproved(
                userAddress: account,
                supply: Decimal(100)
            ).done { needApprove in
                if(needApprove) {
                    savingsService.approveSupplying(
                        supply: Decimal(100),
                        account: privateKey
                    ).done { txHash in
                        print("TX hash")
                        print("0x" + txHash)
                    }.catch { error in
                        print("Approving error")
                        print(error)
                    }
                } else {
                    print("Approve is not needed")
                    savingsService.addSupply(
                        supply: Decimal(0.1),
                        account: privateKey
                    ).done { txHash in
                        print("TX hash for supply")
                        print("0x" + txHash)
                    }.catch { error in
                        print("Supplying error")
                        print(error)
                    }
                }
            }
            
            
            
        } catch { error
            print("error appeared")
            print(error)
        }
    }
}
