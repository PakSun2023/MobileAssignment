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
    
    @State var recentJobs: [Job] = []
    @State var isFetchingJobs: Bool = true
    
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                if let myProfile{
                    VStack(spacing:10){
                        HStack(spacing: 10){
                            Text("Username:")
                            Text(myProfile.username)
                            Spacer()
                        }
                        HStack(spacing: 10){
                            Text("Email:")
                            Text(myProfile.userEmail)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
                
                LazyVStack{
                    if isFetchingJobs {
                        ProgressView()
                            .padding(.top, 25)
                    } else {
                        if recentJobs.isEmpty {
                            Text("No New Jobs Found")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }else {
                            Jobs()
                        }
                    }
                }
                .padding(20)
            }
            .refreshable {
                isFetchingJobs = true
                myProfile = nil
                await fetchUserInfo()
                await fetchJobs()
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
            await fetchJobs()
        }
        
    }
    
    @ViewBuilder
    func Jobs() -> some View {
        ForEach(recentJobs) {job in
            JobCardView(job: job, onDelete: {
                withAnimation(.easeOut(duration: 0.3)){
                    recentJobs.removeAll{job.id == $0.id}
                }
            })
            
            Divider()
                .padding(.horizontal, -20)
        }
    }
    
    func fetchJobs() async {
        do {
            guard let userUID = Auth.auth().currentUser?.uid else{return}
            
            var query: Query!
            query = Firestore.firestore().collection("Jobs")
                .whereField("userUID", isEqualTo: userUID)
            
            let docs = try await query.getDocuments()
            let fetchedJobs = docs.documents.compactMap {doc -> Job? in
                try? doc.data(as: Job.self)
            }
            
            await MainActor.run(body: {
                recentJobs = fetchedJobs
                isFetchingJobs = false
            })
        }catch {
            print(error.localizedDescription)
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
