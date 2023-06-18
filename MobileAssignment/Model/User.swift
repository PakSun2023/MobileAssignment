//
//  User.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 18/6/2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userUID: String
    var userEmail: String
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userUID
        case userEmail
    }
}

