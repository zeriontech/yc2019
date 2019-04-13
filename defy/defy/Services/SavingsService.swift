//
//  SavingsService.swift
//  defy
//
//  Created by Vadim Koleoshkin on 13/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation
import Web3Swift

class CompoudService {
    
    let daiAddress: EthAddress
    let daiContract: ERC20Wrapper
    let daiDecimals = 18
    
    let compoundAddress: EthAddress
    //let compoundContract: CompoundWrapper
    
    let provider: Web3
    
    let utils = EthereumUtils.shared
    
    init(network: Network) throws {
        self.provider = provider
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

extension CompoudService {
    
    // Calls
    //    func getSupplied(userAddress: EthereumAddress) -> Promise<Decimal> {
    //        return firstly {
    //            self.compoundContract.getSupplyBalance(
    //                userAddress: userAddress,
    //                assetAddress: self.daiAddress
    //            ).call()
    //        }.map { outputs in
    //            return try self.decodeSupply(param: outputs["_supply"] as Any)
    //        }
    //    }
    
    func getAvailableSupply(userAddress: EthAddress) -> Promise<Decimal> {
        return await {
            try self.daiContract.balanceOf(
                owner: userAddress
            )
            }.map { balance in
                try self.decodeSupply(balance)
        }
    }
    
    func supplyingIsApproved(userAddress: EthereumAddress, supply: Decimal) -> Promise<Bool> {
        return async {
            self.daiContract.allowance(
                owner: userAddress,
                spender: compoundAddress
            )
            }.map { remaining in
                return try self.decodeSupply(
                    remaining
                    ) >= supply
        }
    }
    
}

extension CompoudService {
    
    // Approve spending of DAI for Compound contract
    func approveSupplying(userAddress: EthereumAddress, supply:Decimal) throws -> Promise<EthereumData> {
        let approveAmount =  NSDecimalNumber(decimal: supply+1).intValue
        
        // Dirty hack, sorry
        guard let rawApproveAmount = BigUInt(approveAmount.description+String(repeating: "0", count: daiDecimals), radix: 10) else {
            throw EthereumUtilsErrors.invalidDecimal
        }
        
        guard let tx = self.daiContract.approve(
            spender: self.compoundAddress,
            value: rawApproveAmount
            ).createTransaction(
                nonce: nil, // Calculated on bitski side
                from: userAddress,
                value: EthereumQuantity(quantity: 0.eth),
                gas: 200000,
                gasPrice: nil // Calculated on bitski side
            ) else {
                throw EthereumUtilsErrors.invalidTx
        }
        
        return firstly {
            self.provider.eth.sendTransaction(
                transaction: tx
            )
        }
    }
    
}

extension CompoudService {
    
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
