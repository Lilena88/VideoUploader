//
//  ErrorPublisher.swift
//  VideoUploader
//
//  Created by Elena Kim on 1/2/24.
//

import Foundation

class ErrorPublisher: ObservableObject {
    static let shared = ErrorPublisher()
    
    @Published var error: Error?
    
    func sendError(_ error: Error) {
        self.error = error
    }
    
}
