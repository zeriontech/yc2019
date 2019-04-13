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
    
    let rateModelAddress: EthAddress
    let rateModelContract: CompoundRateModelWrapper
    // blocks per year to callculate annual return
    let blocksPerYear: Int = 2102400
    
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
        
        self.rateModelAddress = EthAddress(
            hex: "0x8ac03DF808efAe9397A9D95888230eE022B997F4"
        )
        self.rateModelContract = CompoundRateModelWrapper(
            contract: rateModelAddress,
            network: network
        )
    }
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
    
    func getSupplyRate() throws -> Promise<Decimal> {
        
        let market = async {
            try self.compoundContract.markets(
                market: self.daiAddress
            )
        }
        
        let supply = async {
            try self.daiContract.balanceOf(
                owner: self.compoundAddress
            )
        }
        
        let totalBorrows = try await(market).totalBorrows
        let totalSupply = try await(supply)
       
        return async {
            try self.rateModelContract.getSupplyRate(
                market: self.daiAddress,
                supply: totalSupply,
                borrow: totalBorrows
            )
        }.map { supplyRate in
            try self.utils.bytesToNormalizedDecimal(
                number: UnsignedNumbersProduct(terms: [
                    supplyRate,
                    EthNumber(value: self.blocksPerYear) // blocks per year
                ]),
                decimals: 18
            )
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
