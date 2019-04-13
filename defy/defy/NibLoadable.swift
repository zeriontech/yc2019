//
//  NibLoadable.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit

protocol NibLoadable: class {
    static var nibName: String { get }
}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

protocol ViewReusable: class {
    static var defaultReuseIdentifier: String { get }
}

extension ViewReusable where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
