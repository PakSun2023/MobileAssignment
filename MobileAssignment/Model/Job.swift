//
//  Job.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 24/6/2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Job: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var imagesURL: [URL]?
    var assignTo: String?
    var username: String
    var userUID: String
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case description
        case imagesURL
        case assignTo
        case username
        case userUID
    }
}
