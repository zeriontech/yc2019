//
//  ViewController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit
//import Bitski
//import Web3
import PromiseKit
import CryptoSwift
import Web3Swift
import AwaitKit
import LinkKit

enum TableItem {
    
    case card, manage, transaction
    
    var height: Double {
        switch self {
        case .card:
            return 280
        case .manage:
            return 90
        case .transaction:
            return 80
        }
    }
}

class ViewController: UITableViewController {
    
    //var web3: Web3?
    
    var items: [TableItem] = [.card, .manage]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAccount()
        // Do any additional setup after loading the view.
       
        tableView.register(cellClass: CardTableView.self)
        tableView.register(cellClass: ManageTableView.self)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        
    }
  
    func getAccount() {
        
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        self.present(linkViewController, animated: true)
        
        do {
            let privateKey = EthPrivateKey(
                hex: "YOUR_PRIVATE_KEY"
            )
            
            let address = EthAddress(hex: try privateKey.address().value().toHexString())
            var addressHex = try address.value().toHexString()
            addressHex = "0x"+addressHex
            
            let message = "EM3AMPYQZ4"
            
            print(try EthereumUtils.shared.singMessage(message: message, signer: privateKey))
            
            let network = AlchemyNetwork(
                chain: "mainnet", apiKey: "ETi2ntZoWxd6nTI1qE13Q4I1eLB8AMDl"
            )
            
            let savingsService = SavingsService(network: network)
            
            let account = address
            savingsService.getAvailableSupply(userAddress: account).done { balance in
                print("DAI Balance")
                print(balance)
            }.catch { error in
                print("DAI error")
                print(error)
            }
            
            savingsService.getSupplied(userAddress: account).done { balance in
                print("Compound Balance")
                print(balance)
            }.catch { error in
                print("Compound error")
                print(error)
            }
            
            savingsService.supplyingIsApproved(
                userAddress: account,
                supply: Decimal(100)
            ).done { needApprove in
                if(needApprove) {
                    savingsService.approveSupplying(
                        supply: Decimal(100),
                        account: privateKey
                    ).done { txHash in
                        print("TX hash")
                        print("0x" + txHash)
                    }.catch { error in
                        print("Approving error")
                        print(error)
                    }
                } else {
                    print("Approve is not needed")
//                    savingsService.addSupply(
//                        supply: Decimal(0.1),
//                        account: privateKey
//                    ).done { txHash in
//                        print("TX hash for supply")
//                        print("0x" + txHash)
//                    }.catch { error in
//                        print("Supplying error")
//                        print(error)
//                    }
                }
            }
            
            try savingsService.getSupplyRate().done { rate in
                print("Rate: ")
                print(rate)
            }.catch { error in
                print("Error in fetching rates")
            }
            

        } catch { error
            print("error appeared")
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Account"
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "more-filled-black"), for: .normal)
//        button.addTarget(self, action: #selector(self.moreButtonTapHandler), for: .touchUpInside)
        button.tintColor = .black
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

//    func getAccount() {
////        if let web3 = self.web3 {
////            firstly {
////                web3.eth.accounts().firstValue
////            }.done { [weak self] account in
////                print(account.hex(eip55: true))
////
////            }
////        }
//
//    }
    
    @objc func deposit() {
        if let navigationController = self.navigationController as? MainViewController {
            //            navigationController.navigationItem.setHidesBackButton(true, animated: false)
            //            navigationController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
            navigationController.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)]
            navigationController.navigationBar.setNeedsDisplay()
            //            navigationController.navigationItem.hidesBackButton = true
            //            navigationController.isNavigationBarHidden = true
        }
        
//        Bitski.shared = Bitski(clientID: BitskiClientID,
//                               redirectURL: URL(string: BitskiRedirectURL)!)
//        Bitski.shared?.signIn() { error in
//            // Once signed in, get an instance of Web3
//            self.web3 = Bitski.shared?.getWeb3()
//            self.getAccount()
//        }
    }
}

extension ViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController:
        PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken:
        String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            NSLog("Successfully linked account!\npublicToken: (publicToken)\nmetadata: (metadata ?? [:])")
//                self.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }
    
    func linkViewController(_ linkViewController:
        PLKPlaidLinkViewController, didExitWithError error: Error?,
                                    metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: (error.localizedDescription)\nmetadata: (metadata ?? [:])")
//                self.handleError(error, metadata: metadata)
            }
            else {
                NSLog("Plaid link exited with metadata: (metadata ?? [:])")
//                self.handleExitWithMetadata(metadata)
            }
        }
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.row] {
        case .card:
            let cell: CardTableView = tableView.dequeueReusableCell(for: indexPath)
            cell.setBalance(balance: 1256.54)
            return cell
        case .manage:
            let cell: ManageTableView = tableView.dequeueReusableCell(for: indexPath)
            cell.depositButton.addTarget(self, action: #selector(deposit), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.row].height.toCGFloat()
    }
}
