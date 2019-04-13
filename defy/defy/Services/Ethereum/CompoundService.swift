//
//  DaiService.swift
//  defy
//
//  Created by Vadim Koleoshkin on 12/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Web3Swift
import AwaitKit
import PromiseKit

class CompoundWrapper {
    
    let interactor: ContractInteractor
    let encoder: CompoundEncoder
    let decoder: CompoundDecoder
    
    public init(
        contract: EthAddress,
        network: Network
    ) {
        self.interactor = ContractInteractor(
            contract: contract,
            network: network
        )
        self.encoder = CompoundEncoder()
        self.decoder = CompoundDecoder()
    }
    
    public func getSupplyBalance(userAddress: EthAddress, assetAddress: EthAddress) throws -> EthNumber {
        return try decoder.decodeNumber(
            message: interactor.call(
                function: encoder.getSupplyBalance(
                    address: userAddress,
                    asset: assetAddress
                )
            )
        )
    }
    
    public func markets(market: EthAddress) throws -> CompoundDecoder.Market {
        return try decoder.decodeMarket(
            message: interactor.call(
                function: encoder.markets(asset: market)
            )
        )
    }
    
    public func supply(assetAddress: EthAddress, amount: EthNumber, sender: EthPrivateKey) throws -> BytesScalar {
        return try interactor.send(
            function: encoder.supply(
                asset: assetAddress, amount: amount
            ),
            value: EthNumber(value: 0),
            sender:  sender
        )
    }
}

class CompoundEncoder {
    
    func getSupplyBalance(address: EthAddress, asset:EthAddress) -> EncodedABIFunction {
        return EncodedABIFunction(
            signature: "getSupplyBalance(address,address)",
            parameters: [
                ABIAddress(
                    address: address
                ),
                ABIAddress(
                    address: asset
                )
            ]
        )
    }
    
    func supply(asset: EthAddress, amount:EthNumber) -> EncodedABIFunction {
        return EncodedABIFunction(
            signature: "supply(address,uint256)",
            parameters: [
                ABIAddress(
                    address: asset
                ),
                ABIUnsignedNumber(
                    origin: amount
                )
            ]
        )
    }
    
    func markets(asset: EthAddress) -> EncodedABIFunction {
        return EncodedABIFunction(
            signature: "markets(address)",
            parameters: [
                ABIAddress(
                    address: asset
                )
            ]
        )
    }
    
}

class CompoundDecoder: ABIDecoder {
    
    // Market
    public struct Market {
        // #2 interest rate model
        let interestRateModel: EthAddress
        // #3 total supply from contract function
        let totalSupply: EthNumber
        // #6 total borrowed from contract function
        let totalBorrows: EthNumber
    }
    
    func decodeMarket(message: ABIMessage) throws -> Market {
        
        return try Market(
            interestRateModel: EthAddress(
                bytes: SimpleBytes(
                    bytes: DecodedABIAddress(
                        abiMessage: message,
                        index: 2
                    ).value()
                )
            ),
            totalSupply: EthNumber(
                hex: SimpleBytes(
                    bytes: DecodedABINumber(
                        abiMessage: message,
                        index: 3
                    ).value()
                )
            ),
            totalBorrows: EthNumber(
                hex: SimpleBytes(
                    bytes: DecodedABINumber(
                        abiMessage: message,
                        index: 6
                        ).value()
                )
            )
        )
    }
    
}

class CompoundRateModelWrapper {
    
    let interactor: ContractInteractor
    let encoder: CompoundRateModelEncoder
    let decoder: CompoundRateModelDecoder
    
    public init(contract: EthAddress, network: Network) {
        self.interactor = ContractInteractor(
            contract: contract, network: network
        )
        self.decoder = CompoundRateModelDecoder()
        self.encoder = CompoundRateModelEncoder()
    }
    
    public func getSupplyRate(market: EthAddress, supply: EthNumber, borrow: EthNumber) throws -> EthNumber {
        
        return try decoder.decodeSupplyRate(
            message: interactor.call(
                function: encoder.getSupplyRate(
                    market: market,
                    supply: supply,
                    borrow: borrow
                )
            )
        )
    }
    
}

class CompoundRateModelEncoder: ABIEncoder {
    
    func getSupplyRate(market: EthAddress, supply: EthNumber, borrow: EthNumber) -> EncodedABIFunction {
        return EncodedABIFunction(
            signature: "getSupplyRate(address,uint256,uint256)",
            parameters: [
                ABIAddress(
                    address: market
                ),
                ABIUnsignedNumber(
                    origin: supply
                ),
                ABIUnsignedNumber(
                    origin: borrow
                )
            ]
        )
    }
    
}

class CompoundRateModelDecoder: ABIDecoder {
    func decodeSupplyRate(message: ABIMessage) throws -> EthNumber {
        return try EthNumber(
            hex: DecodedABINumber(
                abiMessage: message,
                index: 1
            ).value().toHexString()
        )
    }
}
