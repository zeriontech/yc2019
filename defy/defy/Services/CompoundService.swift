//
//  DaiService.swift
//  defy
//
//  Created by Vadim Koleoshkin on 12/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

////import Web3
//
//class CompoudService {
//    
//    let daiAddress: EthereumAddress
//    let daiContract: GenericERC20Contract
//    let daiDecimals = 18
//    
//    let compoundAddress: EthereumAddress
//    let compoundContract: CompoundWrapper
//    
//    let provider: Web3
//    
//    let utils = EthereumUtils.shared
//    
//    init(provider: Web3) throws {
//        self.provider = provider
//        self.daiAddress = try EthereumAddress(hex: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359", eip55: false)
//        self.daiContract = self.provider.eth.Contract(type: GenericERC20Contract.self, address: self.daiAddress)
//        self.compoundAddress = try EthereumAddress(hex: "0x3fda67f7583380e67ef93072294a7fac882fd7e7", eip55: false)
//        self.compoundContract = self.provider.eth.Contract(type: CompoundWrapper.self, address: self.compoundAddress)
//    }
//    
//    // Transactions
////    func addSupply(supply: Decimal, userAccount: EthereumPrivateKey) throws -> Promise<EthereumData> {
////        
////        let userAddress = userAccount.address
////        let supplyAmount =  NSDecimalNumber(decimal: supply).intValue
////        
////        // Dirty hack, sorry
////        guard let rawSupplyAmount = BigUInt(supplyAmount.description+String(repeating: "0", count: daiDecimals), radix: 10) else {
////            throw EthereumUtilsErrors.invalidDecimal
////        }
////        return firstly {
////            self.provider.eth.getTransactionCount(address: userAddress, block: .latest)
////        }.then { nonce in
////            guard let tx = self.compoundContract.supply(
////                assetAddress: daiAddress,
////                amount: rawSupplyAmount
////            ).createTransaction(
////                nonce: nonce, // Calculated on bitski side
////                from: userAddress,
////                value: EthereumQuantity(quantity: 0.eth),
////                gas: 200000,
////                gasPrice: EthereumQuantity(quantity: 12.gwei) // Calculated on bitski side
////            ) else {
////                throw EthereumUtilsErrors.invalidTx
////            }
////            let tx = try EthereumTransaction(
////                nonce: nonce,
////                gasPrice: EthereumQuantity(quantity: 12.gwei),
////                gas: 22000,
////                to: userAddress,
////                value: EthereumQuantity(quantity: 0.001.eth)
////            )
////            return self.provider.eth.sendRawTransaction(
////                transaction: tx.sign(with: userAccount, chainId: 1)
////            )
////        }
////        
////    }
//}
//
//extension CompoudService {
//    
//    // Calls
//    func getSupplied(userAddress: EthereumAddress) -> Promise<Decimal> {
//        return firstly {
//            self.compoundContract.getSupplyBalance(
//                userAddress: userAddress,
//                assetAddress: self.daiAddress
//                ).call()
//        }.map { outputs in
//            return try self.decodeSupply(param: outputs["_supply"] as Any)
//        }
//        
//    }
//    
//    func getAvailableSupply(userAddress: EthereumAddress) -> Promise<Decimal> {
//        return firstly {
//            self.daiContract.balanceOf(
//                address: userAddress
//                ).call()
//        }.map { outputs in
//            return try self.decodeSupply(param: outputs["_balance"] as Any)
//        }
//    }
//    
//    func supplyingIsApproved(userAddress: EthereumAddress, supply: Decimal) -> Promise<Bool> {
//        return firstly {
//            self.daiContract.allowance(
//                owner: userAddress,
//                spender: compoundAddress
//            ).call()
//        }.map { outputs in
//            return try self.decodeSupply(
//                param: outputs["_remaining"] as Any
//            ) >= supply
//        }
//    }
//    
//}
//
//extension CompoudService {
//    
//    // Approve spending of DAI for Compound contract
//    func approveSupplying(userAddress: EthereumAddress, supply:Decimal) throws -> Promise<EthereumData> {
//        let approveAmount =  NSDecimalNumber(decimal: supply+1).intValue
//        
//        // Dirty hack, sorry
//        guard let rawApproveAmount = BigUInt(approveAmount.description+String(repeating: "0", count: daiDecimals), radix: 10) else {
//            throw EthereumUtilsErrors.invalidDecimal
//        }
//        
//        guard let tx = self.daiContract.approve(
//            spender: self.compoundAddress,
//            value: rawApproveAmount
//        ).createTransaction(
//                nonce: nil, // Calculated on bitski side
//                from: userAddress,
//                value: EthereumQuantity(quantity: 0.eth),
//                gas: 200000,
//                gasPrice: nil // Calculated on bitski side
//        ) else {
//                throw EthereumUtilsErrors.invalidTx
//        }
//        
//        return firstly {
//            self.provider.eth.sendTransaction(
//                transaction: tx
//            )
//        }
//    }
//    
//}
//
//extension CompoudService {
//    
//    private func decodeSupply(param: Any) throws -> Decimal {
//        guard let rawSupply = param as? BigUInt else {
//            throw EthereumUtilsErrors.invalidBigUInt
//        }
//        
//        guard let rawDecimal = Decimal(string: rawSupply.description) else {
//            throw EthereumUtilsErrors.invalidDecimal
//        }
//        
//        let supply = self.utils.normalizedDecimal(
//            number: rawDecimal,
//            decimals: self.daiDecimals
//        )
//        
//        return supply
//    }
//    
//}
//
//class CompoundWrapper: StaticContract {
//    var events: [SolidityEvent]
//    
//    public var address: EthereumAddress?
//    public let eth: Web3.Eth
//    
//    public required init(address: EthereumAddress?, eth: Web3.Eth) {
//        self.address = address
//        self.eth = eth
//        self.events = []
//    }
//    
//    public func getSupplyBalance(userAddress: EthereumAddress, assetAddress: EthereumAddress) -> SolidityInvocation {
//        let inputs = [
//            SolidityFunctionParameter(name: "_owner", type: .address),
//            SolidityFunctionParameter(name: "_asset", type: .address)
//        ]
//        let outputs = [SolidityFunctionParameter(name: "_supply", type: .uint256)]
//        let method = SolidityConstantFunction(
//            name: "getSupplyBalance",
//            inputs: inputs,
//            outputs: outputs,
//            handler: self
//        )
//        return method.invoke(userAddress, assetAddress)
//    }
//    
//    public func supply(assetAddress: EthereumAddress, amount: BigUInt) -> SolidityInvocation {
//        let inputs = [
//            SolidityFunctionParameter(name: "_asset", type: .address),
//            SolidityFunctionParameter(name: "_amount", type: .uint)
//        ]
//        let outputs = [SolidityFunctionParameter(name: "_supplied", type: .uint)]
//        let method = SolidityNonPayableFunction(
//            name: "supply",
//            inputs: inputs,
//            outputs: outputs,
//            handler: self
//        )
//        return method.invoke(assetAddress, amount)
//    }
//}
