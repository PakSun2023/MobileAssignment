//
//  ChatMessage.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 27/6/2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var fromId: String
    var text: String
    var audioURL: URL?
    var timestamp: Date = Date()
    
    enum CodingKeys: CodingKey {
        case id
        case fromId
        case text
        case audioURL
        case timestamp
    }
}
