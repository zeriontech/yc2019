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
    
}

class CompoundDecoder: ABIDecoder {
    
}
