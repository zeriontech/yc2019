//
//  ViewController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit
import Bitski
import Web3
import PromiseKit
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
    
    var web3: Web3?
    
    var items: [TableItem] = [.card, .manage]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Replace redirect URL with an url scheme that will hit your native app
        Bitski.shared = Bitski(clientID: BitskiClientID,
                               redirectURL: URL(string: BitskiRedirectURL)!)
        
        Bitski.shared?.signIn() { error in
            // Once signed in, get an instance of Web3
            self.web3 = Bitski.shared?.getWeb3()
            self.getAccount()
        }
        
//        if Bitski.shared?.isLoggedIn == true {
//            self.web3 = Bitski.shared?.getWeb3()
//            // show logged in state
//        } else {
//            // show logged out state
//        }
        
        tableView.register(cellClass: CardTableView.self)
        tableView.register(cellClass: ManageTableView.self)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
    }

    func getAccount() {
        if let web3 = self.web3 {
            firstly {
                web3.eth.accounts().firstValue
            }.done { [weak self] account in
                print(account.hex(eip55: true))
                // With shared configuration from Info.plist
                if let self = self {
                    let linkViewDelegate = self
                    let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
                    if (UI_USER_INTERFACE_IDIOM() == .pad) {
                        linkViewController.modalPresentationStyle = .formSheet;
                    }
                    self.present(linkViewController, animated: true)
                }
            }
        }
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
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.row].height.toCGFloat()
    }
}
