//
//  NumberFormatter+Formatters.swift
//  FlashExample
//
//  Created by Conor Mulligan on 16/05/2023.
//

import Foundation

extension NumberFormatter {

    static var integer: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }

    static var decimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}
