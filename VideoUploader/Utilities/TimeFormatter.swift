//
//  TimeFormatter.swift
//  VideoUploader
//
//  Created by Elena Kim on 1/5/24.
//

import Foundation

extension TimeInterval {
    func formatTimeInterval(allowedUnits: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self)
    }
}
