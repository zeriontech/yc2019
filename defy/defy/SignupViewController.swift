//
//  SignupViewController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit

enum SignupItem {
    
    case simple(String), phone, birthday
    
    var title: String {
        switch self {
        case .simple(let label):
            return label
        case .phone:
            return "+1"
        case .birthday:
            return "Birthday"
        }
    }
}

class SignupViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var title_: String = ""
    var subtitle: String = ""
    var items: [SignupItem] = []
    
    let flowController = SignupFlowController.shared
    
    var step: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass: SimpleInputCell.self)
        tableView.tableFooterView = UIView()
        
        setupViewController()
    }
    
    func configure(step: Int) {
        self.step = step
        let (title, subtitle, items) = flowController.getConfig(step: step)
        self.title_ = title
        self.subtitle = subtitle
        self.items = items
    }
    
    func setupViewController() {
        self.titleLabel.text = title_
        self.subtitleLabel.text = subtitle
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("tap")
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let navigationController = self.navigationController {
            if flowController.isLastStep(step: self.step) {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
                vc.configure(step: self.step + 1)
                navigationController.pushViewController(vc, animated: true)
            } else {
                
            }
            
        }
        return true
    }
}

extension SignupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SimpleInputCell = tableView.dequeueReusableCell(for: indexPath)
        let item = self.items[indexPath.row]
        
        if indexPath.row == 0 {
            cell.textField.becomeFirstResponder()
        }
        cell.textField.delegate = self
        
        switch item {
        case .simple(let label):
            cell.label.text = label
        case .phone:
            cell.label.text = "Phone"
        case .birthday:
            cell.label.text = item.title
        }
        return cell
    }
    
    
}

