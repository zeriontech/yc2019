//
//  UIColor.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/13/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import UIKit

extension UIColor {
    static let backgroundColor = UIColor(red: 243/255, green: 242/255, blue: 249/255, alpha: 1)
    static let darkColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
}


extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 47.5, height: 47.5)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
