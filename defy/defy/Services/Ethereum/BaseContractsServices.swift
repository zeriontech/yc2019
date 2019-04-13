//
//  BaseContractsServices.swift
//  defy
//
//  Created by Vadim Koleoshkin on 13/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation
import Web3Swift

class ABIEncoder {
    
    func encode(function: String, parameters: [ABIEncodedParameter]) -> EncodedABIFunction {
        return EncodedABIFunction(
            signature: function,
            parameters: parameters
        )
    }
    
}

class ContractInteractor {
    
    let network: Network
    let contract: EthAddress
    
    init(contract: EthAddress, network: Network) {
        self.contract = contract
        self.network = network
    }
    
    func call(function: EncodedABIFunction) throws -> ABIMessage {
        return try ABIMessage(
            message: EthContractCall(
                network: network,
                contractAddress: contract,
                functionCall:
                function
                ).value().toHexString()
        )
    }
    
}
