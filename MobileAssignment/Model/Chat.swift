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
    var jobTitle: String
    var jobOwnerId: String
    var jobOwner: String
    var jobRequestId: String
    var jobRequest: String
    
    enum CodingKeys: CodingKey {
        case id
        case jobId
        case jobTitle
        case jobOwnerId
        case jobOwner
        case jobRequestId
        case jobRequest
    }
}
