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
    let compoundContract: CompoundWrapper
    
    let provider: Web3
    
    let utils = EthereumUtils.shared
    
    init(provider: Web3) throws {
        self.provider = provider
        self.daiAddress = try EthereumAddress(hex: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359", eip55: false)
        self.daiContract = self.provider.eth.Contract(type: GenericERC20Contract.self, address: self.daiAddress)
        self.compoundAddress = try EthereumAddress(hex: "0x3fda67f7583380e67ef93072294a7fac882fd7e7", eip55: false)
        self.compoundContract = self.provider.eth.Contract(type: CompoundWrapper.self, address: self.compoundAddress)
    }
    
    // Transactions
//    func addSupply(address: EthereumAddress) throws -> BigUInt {
//
//    }
//
//
    func approveSupplying(userAddress: EthereumAddress, supply:Decimal) throws -> Promise<EthereumData> {
        
        let rawApproveAmount = supply*pow(10, self.daiDecimals) as Decimal
        
        // Not sure about overflow
        let hexString = String(
            NSDecimalNumber(decimal: rawApproveAmount).intValue,
            radix: 16
        )
        
        guard let approveAmount = BigUInt(
            hexString: hexString
        ) else {
            throw EthereumUtilsErrors.invalidDecimal
        }
        
        guard let tx = self.daiContract.approve(
            spender: userAddress,
            value: approveAmount
        ).createTransaction(
            nonce: nil,
            from: userAddress,
            value: EthereumQuantity(quantity: 0.eth),
            gas: 200000,
            gasPrice: EthereumQuantity(quantity: 1.gwei)
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
    
    // Calls
    func getSupplied(userAddress: EthereumAddress) -> Promise<Decimal> {
        return firstly {
            self.compoundContract.getSupplyBalance(
                userAddress: userAddress,
                assetAddress: self.daiAddress
                ).call()
        }.map { outputs in
            return try self.decodeSupply(param: outputs["_supply"] as Any)
        }
        
    }
    
    func getAvailableSupply(userAddress: EthereumAddress) -> Promise<Decimal> {
        return firstly {
            self.daiContract.balanceOf(
                address: userAddress
                ).call()
        }.map { outputs in
            return try self.decodeSupply(param: outputs["_balance"] as Any)
        }
    }
    
    func supplyingIsApproved(userAddress: EthereumAddress, supply: Decimal) -> Promise<Bool> {
        return firstly {
            self.daiContract.allowance(
                owner: userAddress,
                spender: compoundAddress
            ).call()
        }.map { outputs in
            return try self.decodeSupply(
                param: outputs["_remaining"] as Any
            ) >= supply
        }
    }
    
}

extension CompoudService {
    
    private func decodeSupply(param: Any) throws -> Decimal {
        guard let rawSupply = param as? BigUInt else {
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

class CompoundWrapper: StaticContract {
    var events: [SolidityEvent]
    
    public var address: EthereumAddress?
    public let eth: Web3.Eth
    
    public required init(address: EthereumAddress?, eth: Web3.Eth) {
        self.address = address
        self.eth = eth
        self.events = []
    }
    
    public func getSupplyBalance(userAddress: EthereumAddress, assetAddress: EthereumAddress) -> SolidityInvocation {
        let inputs = [
            SolidityFunctionParameter(name: "_owner", type: .address),
            SolidityFunctionParameter(name: "_asset", type: .address)
        ]
        let outputs = [SolidityFunctionParameter(name: "_supply", type: .uint256)]
        let method = SolidityConstantFunction(
            name: "getSupplyBalance",
            inputs: inputs,
            outputs: outputs,
            handler: self
        )
        return method.invoke(userAddress, assetAddress)
    }
}
