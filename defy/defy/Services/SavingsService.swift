//
//  SavingsService.swift
//  defy
//
//  Created by Vadim Koleoshkin on 13/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation
import Web3Swift
import AwaitKit
import PromiseKit

class SavingsService {
    
    let daiAddress: EthAddress
    let daiContract: ERC20Wrapper
    let daiDecimals = 18
    
    let compoundAddress: EthAddress
    let compoundContract: CompoundWrapper
    
    let provider: Network
    
    let utils = EthereumUtils.shared
    
    init(network: Network) {
        self.provider = network
        self.daiAddress = EthAddress(
            hex: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359"
        )
        self.daiContract = ERC20Wrapper(
            contract: daiAddress,
            network: network
        )
        self.compoundAddress = EthAddress(
            hex: "0x3fda67f7583380e67ef93072294a7fac882fd7e7"
        )
        self.compoundContract = CompoundWrapper(
            contract: compoundAddress,
            network: network
        )
    }
    
    // Transactions
    //    func addSupply(supply: Decimal, userAccount: EthereumPrivateKey) throws -> Promise<EthereumData> {
    //
    //        let userAddress = userAccount.address
    //        let supplyAmount =  NSDecimalNumber(decimal: supply).intValue
    //
    //        // Dirty hack, sorry
    //        guard let rawSupplyAmount = BigUInt(supplyAmount.description+String(repeating: "0", count: daiDecimals), radix: 10) else {
    //            throw EthereumUtilsErrors.invalidDecimal
    //        }
    //        return firstly {
    //            self.provider.eth.getTransactionCount(address: userAddress, block: .latest)
    //        }.then { nonce in
    //            guard let tx = self.compoundContract.supply(
    //                assetAddress: daiAddress,
    //                amount: rawSupplyAmount
    //            ).createTransaction(
    //                nonce: nonce, // Calculated on bitski side
    //                from: userAddress,
    //                value: EthereumQuantity(quantity: 0.eth),
    //                gas: 200000,
    //                gasPrice: EthereumQuantity(quantity: 12.gwei) // Calculated on bitski side
    //            ) else {
    //                throw EthereumUtilsErrors.invalidTx
    //            }
    //            let tx = try EthereumTransaction(
    //                nonce: nonce,
    //                gasPrice: EthereumQuantity(quantity: 12.gwei),
    //                gas: 22000,
    //                to: userAddress,
    //                value: EthereumQuantity(quantity: 0.001.eth)
    //            )
    //            return self.provider.eth.sendRawTransaction(
    //                transaction: tx.sign(with: userAccount, chainId: 1)
    //            )
    //        }
    //
    //    }
}

extension SavingsService {
    
     //Calls
    func getSupplied(userAddress: EthAddress) -> Promise<Decimal> {
        return async {
            try self.compoundContract.getSupplyBalance(
                userAddress: userAddress,
                assetAddress: self.daiAddress
            )
        }.map { balance in
            try self.decodeSupply(supply: balance)
        }
    }
    
    func getAvailableSupply(userAddress: EthAddress) -> Promise<Decimal> {
        return async {
            try self.daiContract.balanceOf(
                owner: userAddress
            )
        }.map { balance in
            try self.decodeSupply(supply: balance)
        }
    }
    
    func supplyingIsApproved(userAddress: EthAddress, supply: Decimal) -> Promise<Bool> {
        return async {
            try self.daiContract.allowance(
                owner: userAddress,
                spender: self.compoundAddress
            )
        }.map { remaining in
            print(try HexAsDecimalString(hex: remaining).value())
            return try self.decodeSupply(
                supply: remaining
            ) >= supply
        }
    }
    
}

extension SavingsService {
    
    // Approve spending of DAI for Compound contract
    func approveSupplying(supply:Decimal, account: EthPrivateKey) -> Promise<String> {
        
        let supplyAmount = EthNumber(
            decimal: (supply * pow(10, daiDecimals)).description
        )
        
        return async {
            try self.daiContract.approve(
                spender: self.compoundAddress,
                amount: supplyAmount,
                sender: account
            )
        }.map { txHash in
            let tx = try txHash.value().toHexString()
            print(tx)
            return tx
        }
    }
    
    func addSupply(supply:Decimal, account: EthPrivateKey) -> Promise<String> {
        
        let supplyAmount = EthNumber(
            decimal: (supply * pow(10, daiDecimals)).description
        )
        
        return async {
            try self.compoundContract.supply(
                assetAddress: self.daiAddress,
                amount: supplyAmount,
                sender: account
            )
        }.map { txHash in
            let tx = try txHash.value().toHexString()
            print(tx)
            return tx
        }
    }
    
}

extension SavingsService {
    
    private func decodeSupply(supply: EthNumber) throws -> Decimal {
        
        guard let rawDecimal = Decimal(
            string: try HexAsDecimalString(
                hex: supply
                ).value()
            ) else {
                throw EthereumUtilsErrors.invalidDecimal
        }
        
        let supply = self.utils.normalizedDecimal(
            number: rawDecimal,
            decimals: self.daiDecimals
        )
        
        return supply
    }
    
}
