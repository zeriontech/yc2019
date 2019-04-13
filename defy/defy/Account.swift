//
//  Account.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation
import Web3Swift

class Account {
    static let shared = Account()
    
    var addressHex: String = ""
    var address: EthAddress?
    let privateKey = EthPrivateKey(
        hex: ""
    )
    
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    
    var balance: Double = 0
    var interestRate: Double = 0.06
    
    var isPlaidConnected: Bool = false
    
    func supplyToCompound(amount: Double) {
        let network = AlchemyNetwork(
            chain: "mainnet", apiKey: "ETi2ntZoWxd6nTI1qE13Q4I1eLB8AMDl"
        )
        
        let savingsService = SavingsService(network: network)
        
        guard let address = self.address else {
            return
        }
        savingsService.supplyingIsApproved(
            userAddress: address,
            supply: Decimal(100)
            ).done { needApprove in
                if(needApprove) {
                    savingsService.approveSupplying(
                        supply: Decimal(100),
                        account: self.privateKey
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
                        supply: Decimal(amount),
                        account: self.privateKey
                        ).done { txHash in
                            print("TX hash for supply")
                            print("0x" + txHash)
                        }.catch { error in
                            print("Supplying error")
                            print(error)
                    }
                }
        }
    }
}
