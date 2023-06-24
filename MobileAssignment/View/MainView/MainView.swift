//
//  MainView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 19/6/2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            JobsView()
                .tabItem {
                    Image(systemName: "house.circle")
                    Text("Home")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "gear.circle")
                    Text("Profile")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
