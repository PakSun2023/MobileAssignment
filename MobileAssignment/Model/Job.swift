//
//  Job.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 24/6/2023.
//

import SwiftUI
import FirebaseFirestoreSwift
import Foundation

enum jobStatus: String, Codable {
    case open, progress, cancel, completed
}

struct Job: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var createdDate: Date = Date()
    var status: jobStatus = .open
    var imagesURL: [URL]?
    var assignTo: String?
    var requestBy: String?
    var username: String
    var userUID: String
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case description
        case createdDate
        case status
        case imagesURL
        case assignTo
        case requestBy
        case username
        case userUID
    }
}
