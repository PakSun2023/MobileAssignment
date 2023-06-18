//
//  ProfileView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 19/6/2023.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = false
    @State var editProfile: Bool = false
    @State private var myProfile: User?
    @AppStorage("is_login") var is_logiin: Bool = false
    
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                if let myProfile{
                    Text(myProfile.username)
                }
            }
            .refreshable {
                myProfile = nil
                await fetchUserInfo()
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit") {
                            editProfile = true
                        }
                        Button("Logout", action: userLogout)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .fullScreenCover(isPresented: $editProfile) {
            EditProfileView()
        }
        .alert(errorMsg, isPresented: $showError, actions: {})
        .task {
            if myProfile != nil{return}
            await fetchUserInfo()
        }
        
    }
    
    func userLogout () {
        try? Auth.auth().signOut()
        is_logiin = false
    }
    
    func fetchUserInfo () async {
        Task{
            do{
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
                
                await MainActor.run(body: {
                myProfile = user
                })
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMsg = error.localizedDescription
            showError.toggle()
            isLoading = false
            is_logiin = false
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
