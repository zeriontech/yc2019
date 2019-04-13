//
//  EthreumUtils.swift
//  defy
//
//  Created by Vadim Koleoshkin on 12/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

//import Foundation
import Web3Swift
import CryptoSwift

class EthereumUtils {
    
    static let shared = EthereumUtils()
    
    func stringToNormalizedDecimal(number: String, decimals: Int) throws -> Decimal {
        guard let number = Decimal(string: number) else {
            throw EthereumUtilsErrors.invalidDecimal
        }
        return (decimals == 0) ? number : normalizedDecimal(number: number, decimals: decimals)
    }
    
    func normalizedDecimal(number: Decimal, decimals: Int) -> Decimal {
        return number / pow(Decimal(10), decimals)
    }
    
    func singMessage(message: String, signer: PrivateKey) throws -> String {
        let personalMessage = ConcatenatedBytes(
            bytes: [
                //Ethereum prefix
                UTF8StringBytes(
                    string: "\u{19}Ethereum Signed Message:\n"
                ),
                UTF8StringBytes(string: String(message.count)),
                //message
                UTF8StringBytes(string: message)
            ]
        )
        let hashFunction = SHA3(variant: .keccak256).calculate
        let signature = SECP256k1Signature(
            privateKey: signer,
            message: personalMessage,
            hashFunction: hashFunction
        )
        let contractSignature = ConcatenatedBytes(
            bytes: [
                try signature.r(),
                try signature.s(),
                try EthNumber(value: signature.recoverID().value() + 27)
            ]
        )
        return try contractSignature.value().toHexString()
    }
}

enum EthereumUtilsErrors: Error {
    case invalidDecimal
    case invalidBigUInt
    case invalidTx
}
