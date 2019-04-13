//
//  UITableView.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cellClass: T.Type) where T: ViewReusable {
        register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UITableViewCell>(
        cellClass: T.Type
        ) where T: ViewReusable, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UITableViewCell>(
        cellClasses: [T.Type]
        ) where T: ViewReusable, T: NibLoadable {
        cellClasses.forEach(register)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(
        for indexPath: IndexPath
        ) -> T where T: ViewReusable {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.defaultReuseIdentifier,
            for: indexPath
            ) as? T else {
                fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
}
