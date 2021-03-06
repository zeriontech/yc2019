//
//  ViewController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit
import PromiseKit
import CryptoSwift
import Web3Swift
import AwaitKit
import LinkKit
import Alamofire
import SwiftyJSON

enum TableItem {
    
    case card, manage, transaction(Decimal, String)
    
    var height: Double {
        switch self {
        case .card:
            return 280
        case .manage:
            return 90
        case .transaction(_, _):
            return 80
        }
    }
}

class ViewController: UITableViewController {
    
    //var web3: Web3?
    
    var items: [TableItem] = [.card, .manage, .transaction(Decimal(150), "x")]
    
    let account = Account.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        tableView.register(cellClass: CardTableView.self)
        tableView.register(cellClass: ManageTableView.self)
        tableView.register(cellClass: TransactionViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        account.delegate = self
        getAccount()
    }
  
    func getAccount() {
        do {
            let address = EthAddress(hex: try account.privateKey.address().value().toHexString())
            
            var addressHex = try address.value().toHexString()
            addressHex = "0x" + addressHex
            print(addressHex)
            
            account.address = address
            account.addressHex = addressHex
            
            let verifySignatureURL = "https://verify.testwyre.com/core/blockchain/verifySignature/ETH/\(addressHex)"

            let network = AlchemyNetwork(
                chain: "mainnet", apiKey: "ETi2ntZoWxd6nTI1qE13Q4I1eLB8AMDl"
            )
            
            let savingsService = SavingsService(network: network)
            
            savingsService.getSupplied(userAddress: address).done { balance in
                print("Compound Balance")
                self.account.balance = Double(balance as NSNumber)
            }.catch { error in
                print("Compound error")
                print(error)
            }
            
            try savingsService.getSupplyRate().done { rate in
                print("Rate: ")
                self.account.interestRate = Double(rate as NSNumber)
                self.tableView.reloadData()
            }.catch { error in
                print("Error in fetching rates")
            }
          
            // Put back for production
//            Alamofire.request(verifySignatureURL, method: .post).responseJSON { (response) in
//                let value = response.result.value
//                if let value = value as? NSDictionary {
//                    self.sign(message: value["message"] as! String, id: value["id"] as! String, privateKey: privateKey)
//                }
//            }
        } catch { error
            print("error appeared")
            print(error)
        }
    }
    
    func sign(message: String, id: String, privateKey: EthPrivateKey) {
        var signed_message = ""
        var verification_id = ""
        do {
            signed_message = try EthereumUtils.shared.singMessage(message: message, signer: privateKey)
            verification_id = id
        } catch {error
            print(error)
        }
        getSession(verification_id: verification_id, signed_message: signed_message, renew: false)
    }
    
    func getSession(verification_id: String, signed_message: String, renew: Bool = false) {
        let sessionURL = "https://verify.testwyre.com/core/sessions/auth/signature"
        let parameters: Parameters = [
            "accountType": "INDIVIDUAL",
            "blockchainSignId": verification_id,
            "blockchainSignature": "0x" + signed_message,
            "country": "US",
            "referrerId": "AC_RZ2CU3L8YZZ"
        ]
        if !renew {
            let sessionId = UserDefaults.standard.string(forKey: "sessionId") ?? ""
            let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
            gotSession(sessionId: sessionId, userId: userId)
        } else {
            Alamofire.request(sessionURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                print(response)
                switch response.result {
                case .success(let json):
                    let response = json as! NSDictionary
                    
                    let sessionId = response.object(forKey: "sessionId") as! String
                    let userIdFull = response.object(forKey: "authenticatedAs")!
                    guard let userIdString = userIdFull as? String else {
                        return
                    }
                    let userId = String(userIdString.split(separator: ":")[1])
                    UserDefaults.standard.set(sessionId, forKey: "sessionId")
                    UserDefaults.standard.set(userId, forKey: "userId")
                    self.gotSession(sessionId: sessionId, userId: userId)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func gotSession(sessionId: String, userId: String) {
        print("Got session")
        print(sessionId, userId)
    }
    
    func showPlaid() {
        if account.isPlaidConnected {
            initializeAddMoneyFlow()
            return
        }
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        self.present(linkViewController, animated: true)

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
    
    @objc func deposit() {
        self.showPlaid()
    }
    
    func plaidConnected(publicToken: String, accountId: String) {
        supplyPaymentMethod(publicToken: publicToken, accountId: accountId)
    }
    
    func supplyPaymentMethod(publicToken: String, accountId: String) {
        let url = "https://verify.testwyre.com/core/paymentMethods"
        let sessionId = UserDefaults.standard.string(forKey: "sessionId") ?? ""
        
        let parameters: Parameters = [
            "plaidPublicToken": publicToken,
            "plaidAccountId": accountId,
            "paymentMethodType": "LOCAL_TRANSFER",
            "country": "US"
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(sessionId)",
        ]
        
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers).responseJSON { (response) in
            print(response)
            switch response.result {
            case .success(let jsonValue):
                let json = JSON(jsonValue)
                print("Added payment method", json)
            case .failure(let error):
                print(error)
            }
        }
        initializeAddMoneyFlow()
    }
    
    func initializeAddMoneyFlow() {
        if let navigationController = self.navigationController {
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
            let addMoneyFlow = SignupFlowController(screens: [("Select amount", "", [.addMoney])])
            vc.configure(step: 0, flowController: addMoneyFlow)
            navigationController.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController: PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController:
        PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken:
        String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            UserDefaults.standard.set(publicToken, forKey: "plaidPublicToken")
            guard let data = metadata else {
                return
            }
            if let accounts = data["accounts"] as? NSArray {
                if let account = accounts[0] as? [String: String] {
                    self.plaidConnected(publicToken: publicToken, accountId: account["id"] ?? "")
                }
            }
        }
    }
    
    func linkViewController(_ linkViewController:
        PLKPlaidLinkViewController, didExitWithError error: Error?,
                                    metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
//                self.handleError(error, metadata: metadata)
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
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
            cell.setBalance(balance: account.balance)
            let formattedRate = (account.interestRate * 100).rounded(toPlaces: 2)
            cell.interestRate.text = "\(formattedRate)%"
            return cell
        case .manage:
            let cell: ManageTableView = tableView.dequeueReusableCell(for: indexPath)
            cell.depositButton.addTarget(self, action: #selector(deposit), for: .touchUpInside)
            return cell
        case .transaction(let amount, let hash):
            let cell: TransactionViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setUp(hash: hash, sum: amount)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.row].height.toCGFloat()
    }
}


extension ViewController: ViewControllerDelegate {
    
    func gotHash(amount: Decimal, hash: String) {
        self.items.append(.transaction(amount, hash))
        self.tableView.reloadData()
    }
    
}
