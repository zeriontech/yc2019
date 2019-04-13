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
        return decoder.decodeNumber(
            message: interactor.call(
                function: encoder.getSupplyBalance(
                    address: userAddress,
                    asset: assetAddress
                )
            )
        )
    }
    
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
    
}

class CompoundDecoder: ABIDecoder {
    
}
