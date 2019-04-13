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

class ViewController: UIViewController {
    
    var web3: Web3?

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
