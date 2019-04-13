//
//  EthreumUtils.swift
//  defy
//
//  Created by Vadim Koleoshkin on 12/04/2019.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation
import Web3

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
    
    func getTransactionsCount(address: EthereumAddress, provider: Web3) -> Promise<EthereumQuantity> {
        return provider.eth.getTransactionCount(address: address, block: .pending)
    }
}

enum EthereumUtilsErrors: Error {
    case invalidDecimal
    case invalidBigUInt
    case invalidTx
}
