//
//  Chat.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 27/6/2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var jobId: String
    var jobOwner: String
    var jobRequest: String
    
    enum CodingKeys: CodingKey {
        case id
        case jobId
        case jobOwner
        case jobRequest
    }
}
