//
//  MobileAssignmentApp.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 18/6/2023.
//

import SwiftUI
import Firebase

@main
struct MobileAssignmentApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
