//
//  AuthView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 18/6/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var creatingAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = false
    
    @AppStorage("is_login") var is_login: Bool = false
    @AppStorage("user_name") var user_name: String = ""
    @AppStorage("user_email") var user_email: String = ""
    @AppStorage("user_UID") var user_UID: String = ""
    
    var body: some View {
        VStack(spacing: 10){
            Text("Welcome Back!")
                .font(.title.bold())
                .frame(maxWidth: .infinity,alignment: .leading)
            
            VStack(spacing: 10){
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal,15)
                    .padding(.vertical,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(.gray.opacity(0.5),lineWidth: 1)
                    }
                    .padding(.top,20)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal,15)
                    .padding(.vertical,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(.gray.opacity(0.5),lineWidth: 1)
                    }
                    .padding(.top,5)
                
                Button(action: userLogin){
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity,alignment: .center)
                        .padding(.horizontal,15)
                        .padding(.vertical,10)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.black)
                        }
                }
                .padding(.top,5)
                
                Text("or")
                    .padding(.vertical,30)
                
                HStack(spacing: 10){
                    HStack{
                        Image(systemName: "applelogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .frame(height: 40)
                        
                        Text("Login with Apple")
                            .font(.callout)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(.black)
                    }
                    
                    HStack{
                        Image("google")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .frame(height: 40)
                        
                        Text("Login with Google")
                            .font(.callout)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(.black)
                    }
                }
            }
            
            HStack{
                Text("Still don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Sign Up Now"){
                    creatingAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .frame(maxHeight: .infinity,alignment: .bottom)
        }
        .frame(maxHeight: .infinity,alignment: .top)
        .padding(20)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .fullScreenCover(isPresented: $creatingAccount) {
            RegisterView()
        }
        .alert(errorMsg, isPresented: $showError, actions: {})
    }
    
    func userLogin(){
        isLoading = true
        closeKB()
        Task{
            do{
                try await Auth.auth().signIn(withEmail: email, password: password)
                try await fetchUserInfo()
            }catch{
                await setError(error)
            }
        }
    }
    
    func fetchUserInfo() async throws {
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
        
        await MainActor.run(body: {
            user_UID = userUID
            user_name = user.username
            user_email = user.userEmail
            is_login = true
        })
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMsg = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct RegisterView: View {
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = false
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("is_login") var is_login: Bool = false
    @AppStorage("user_name") var user_name: String = ""
    @AppStorage("user_email") var user_email: String = ""
    @AppStorage("user_UID") var user_UID: String = ""
    
    var body: some View {
        VStack(spacing: 10){
            Text("Hello!")
                .font(.title.bold())
                .frame(maxWidth: .infinity,alignment: .leading)
            
            VStack(spacing: 10){
                TextField("Username", text: $username)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal,15)
                    .padding(.vertical,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(.gray.opacity(0.5),lineWidth: 1)
                    }
                    .padding(.top,20)
                
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal,15)
                    .padding(.vertical,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(.gray.opacity(0.5),lineWidth: 1)
                    }
                    .padding(.top,5)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal,15)
                    .padding(.vertical,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(.gray.opacity(0.5),lineWidth: 1)
                    }
                    .padding(.top,5)
                
                Button(action: userRegister){
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity,alignment: .center)
                        .padding(.horizontal,15)
                        .padding(.vertical,10)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.black)
                        }
                }
                .padding(.top,5)
                
                Text("or")
                    .padding(.vertical,30)
                
                HStack(spacing: 10){
                    HStack{
                        Image(systemName: "applelogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .frame(height: 40)
                        
                        Text("Login with Apple")
                            .font(.callout)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(.black)
                    }
                    
                    HStack{
                        Image("google")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .frame(height: 40)
                        
                        Text("Login with Google")
                            .font(.callout)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal,10)
                    .background{
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(.black)
                    }
                }
            }
            
            HStack{
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                Button("Login Now"){
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .frame(maxHeight: .infinity,alignment: .bottom)
        }
        .frame(maxHeight: .infinity,alignment: .top)
        .padding(20)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .alert(errorMsg, isPresented: $showError, actions: {})
    }
    
    func userRegister(){
        isLoading = true
        closeKB()
        Task{
            do{
                try await Auth.auth().createUser(withEmail: email, password: password)
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                
                let user = User(username: username, userUID: userUID, userEmail: email)
                try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: {
                    error in
                    if error == nil {
                        print("Create user success")
                        is_login = true
                        user_name = username
                        user_email = email
                        user_UID = userUID
                    }
                })
            }catch{
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMsg = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View {
    func closeKB () {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
