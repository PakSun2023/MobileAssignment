//
//  ContentView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 18/6/2023.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("is_login") var is_login: Bool = false
    var body: some View {
        if is_login{
            Text("main view")
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
