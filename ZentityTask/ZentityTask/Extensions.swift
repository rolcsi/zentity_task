//
//  Extensions.swift
//  ZentityTask
//
//  Created by Roland Beke on 11.7.17.
//  Copyright © 2017 Roland Beke. All rights reserved.
//

extension String {
    func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "1", "TRUE":
            return true
        case "False", "false", "no", "0", "FALSE":
            return false
        default:
            return false
        }
    }
}
