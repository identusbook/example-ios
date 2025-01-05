//
//  String+base64.swift
//  FlightTix
//
//  Created by Jon Bauer on 1/4/25.
//

import Foundation

extension String {
    
    func decodeBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func encodeBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
