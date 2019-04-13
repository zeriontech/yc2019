//
//  SignupFlowController.swift
//  defy
//
//  Created by Evgeny Yurtaev on 4/12/19.
//  Copyright © 2019 Zerion. All rights reserved.
//

import Foundation



class SignupFlowController {
    static let shared = SignupFlowController()
    
    var screens: [(String, String, [SignupItem])] = [
        ("Get Started", "Enter your mobile phone number to get started.", [.phone]),
        ("Enter Email Address", "Enter Email Address", [.simple("Email", "user@gmail.com")]),
        ("Enter Full Name", "Enter your full legal name to continue.", [.simple("First name", "Sam"), .simple("Last name", "Smith")])
    ]
    
    func getConfig(step: Int) -> (String, String, [SignupItem]) {
        return screens[step]
    }
    
    func isLastStep(step: Int) -> Bool {
        return step == screens.count - 1
    }
    
    init(screens: [(String, String, [SignupItem])]? = nil) {
        if let screens = screens {
            self.screens = screens
        }
    }
    
}
