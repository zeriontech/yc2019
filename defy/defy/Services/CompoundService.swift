//
//  DaiService.swift
//  defy
//
//  Created by Vadim Koleoshkin on 12/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Web3

class CompoudService {
    
    let daiAddress: EthereumAddress
    let daiContract: GenericERC20Contract
    let daiDecimals = 18
    
    let compoundAddress: EthereumAddress
    
    let provider: Web3
    
    let utils = EthereumUtils.shared
    
    init(provider: Web3) throws {
        self.provider = provider
        self.daiAddress = try EthereumAddress(hex: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359", eip55: false)
        self.daiContract = self.provider.eth.Contract(type: GenericERC20Contract.self, address: self.daiAddress)
        self.compoundAddress = try EthereumAddress(hex: "0x3fda67f7583380e67ef93072294a7fac882fd7e7", eip55: false)
    }
    
    // Calls
//    func getSupplied(address: EthereumAddress) throws -> Decimal {
//
//    }
    
    func getAvailableSupply(userAddress: EthereumAddress) -> Promise<Decimal> {
        
        return firstly {
            self.daiContract.balanceOf(
                address: userAddress
            ).call()
        }.map { outputs in

            guard let rawSupply = outputs["_balance"] as? BigUInt else {
                throw EthereumUtilsErrors.invalidBigUInt
            }
            
            guard let rawDecimal = Decimal(string: rawSupply.description) else {
                throw EthereumUtilsErrors.invalidDecimal
            }
            
            let supply = self.utils.normalizedDecimal(
                number: rawDecimal,
                decimals: self.daiDecimals
            )
            
            return supply
        }
    }
    
    // Transactions
//    func addSupply(address: EthereumAddress) throws -> BigUInt {
//
//    }
//
//    func supplyingIsApproved(address: EthereumAddress) throws -> Bool {
//
//    }
//
//    func approveSupplying() throws -> Bool {
//
//    }
}
