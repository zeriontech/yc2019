# Defy — a better savings account (YC2019)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Twitter Follow](https://img.shields.io/twitter/follow/zerion_io.svg?style=social)
### An app that uses benefits of Decentralized Finance (DeFi) to give people access to high-yield savings accounts.

## Inspiration

For a long time now, most of the banks in the US provide very low savings rates, ranging from 0.01% to 2% annually. Typically, these do not even match the inflation rate. 

At the same time, multiple financial primitives for lending and borrowing emerged on top of Ethereum last year. Using blockchain for executing financial contracts allows to cut the middleman and reduce the costs. Simultaneously, it creates a global money market with more competitive lending and borrowing rates. 

The great thing about it is that it is already available and fully-functional. People can earn high-interest rates on deposits in crypto. The existence of stablecoins such as DAI which price is pegged to the US dollar makes it possible to earn interest on top of fiat currencies as well. At the same time, crypto-to-fiat gateways such as Wyre allow for seamless integration with the traditional financial system (credit cards, bank accounts). 

## What it does

Defy mobile app allows people to connect their bank account, go through a simple KYC procedure, deposit US dollars and start earning interest straight away. The current rate is around 6.4% annually. There is no lockup period, money can be withdrawn at any time.

## How we built it

To make the app work, we integrated several public APIs as well as Compound which is a protocol that runs on Ethereum. We used:

1. Wyre (https://www.sendwyre.com/) to verify user identity and buy DAI (a stablecoin pegged to $1) with the US dollars.
2. Plaid (https://plaid.com/) to connect users' bank accounts
3. Compound (https://compound.finance/) to earn interest on top of DAI
4. Alchemy (https://www.alchemy.com/) to propagate transactions to the Ethereum network
5. Ethereum as the underlying smart-contract technology that enables Open Finance 

## Authors
 - [@evgeth](https://github.com/evgeth), Evgeny Yurtaev 
 - [@rockfridrich](https://github.com/rockfridrich), Vadim Koleoshkin
 - [@bashalex](https://github.com/bashalex), Alex Bashlykov
