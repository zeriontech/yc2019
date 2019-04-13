//
//  ERC20Service.swift
//  defy
//
//  Created by Vadim Koleoshkin on 13/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation
import Web3Swift

class ERC20Wrapper {
    
    let encoder: ERC20Encoder
    let decoder: ERC20Decoder
    let interactor: ContractInteractor
    
    public init(
        contract: EthAddress,
        network: Network
        ) {
        self.interactor = ContractInteractor(
            contract: contract,
            network: network
        )
        self.encoder = ERC20Encoder()
        self.decoder = ERC20Decoder()
    }
    
    func balanceOf(owner: EthAddress) throws -> EthNumber {
        return try decoder.decodeNumber(
            message: interactor.call(
                function: encoder.balanceOf(owner: owner)
            )
        )
    }
    
    func allowance(owner: EthAddress, spender: EthAddress) throws -> EthNumber
    {
        return try decoder.decodeNumber(
            message: interactor.call(
                function: encoder.allowance(
                    owner: spender, spender: spender
                )
            )
        )
    }
    
}

class ERC20Encoder: ABIEncoder {
    
    func balanceOf(owner: EthAddress) -> EncodedABIFunction {
        return encode(
            function: "balanceOf()",
            parameters: [
                ABIAddress(
                    address: owner
                )
            ]
        )
    }
    
    func approve(spender: EthAddress, value: EthNumber) -> EncodedABIFunction {
        return encode(
            function: "approve(address,uint256)",
            parameters: [
                ABIAddress(
                    address: spender
                ),
                ABIUnsignedNumber(
                    origin: value
                ),
            ]
        )
    }
    
    func allowance(owner: EthAddress, spender: EthAddress) -> EncodedABIFunction {
        return encode(
            function: "allowance(address,address)",
            parameters: [
                ABIAddress(
                    address: owner
                ),
                ABIAddress(
                    address: spender
                ),
            ]
        )
    }
}

class ERC20Decoder: ABIDecoder {
    
    
}

class ABIDecoder {
    func decodeNumber(message: ABIMessage) throws -> EthNumber {
        return try EthNumber(
            hex: DecodedABINumber(
                abiMessage: message,
                index: 0
                ).value().toHexString()
        )
    }
    
    func decodeString(message: ABIMessage) throws -> String {
        return try DecodedABIString(abiMessage: message, index: 0).value()
    }
}
