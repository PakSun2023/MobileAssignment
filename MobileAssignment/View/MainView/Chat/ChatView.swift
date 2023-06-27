//
//  ChatView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 27/6/2023.
//

import SwiftUI
import PhotosUI
import Firebase

class ChatViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var chatID = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    init() {
        if chatID != "" {
            fetchMessages()
        }
    }
    
    func fetchMessages() {
        print(chatID)
        print("fetching messages")
        Firestore.firestore().collection("Chats").document(chatID).collection("messages").order(by: "timestamp")
            .addSnapshotListener {querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let chatMsg = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(chatMsg)
                        } catch {
                            print(error)
                        }
                    }
                })}
    }
    
    func onSend() {
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        
        let messageData = ["fromId": userUID, "text": self.chatText, "timestamp": Timestamp()] as [String : Any]
        
        let document = Firestore.firestore().collection("Chats").document(chatID).collection("messages").document()
        
        document.setData(messageData) {error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.chatText = ""
        }
    }
}

struct ChatView: View {
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = true
    @State var showImagePicker: Bool = false
    @State var imageItem: PhotosPickerItem?
    @FocusState var showKB: Bool
    
    @State private var cameraImage = UIImage()
    @State private var showSheet: Bool = false
    
    @ObservedObject var vm = ChatViewModel()
    
    @State var jobInfo: Job?
    
    @AppStorage("chat_id") var chat_id: String = ""
    @AppStorage("user_UID") var user_UID: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            HStack{
                Button("Back", role: .destructive) {
                    dismiss()
                }
                .font(.callout)
                .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            HStack {
                Text("Job:")
                    .font(.callout)
                    .fontWeight(.bold)
                Text(jobInfo?.title ?? "")
                    .font(.caption)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 5) {
                    ForEach(vm.chatMessages) { message in
                        if message.fromId == user_UID {
                            HStack {
                                Spacer()
                                
                                HStack {
                                    
                                    Text(message.text)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        } else {
                            HStack {
                                HStack {
                                    
                                    Text(message.text)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                
                                Spacer()
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                }
            }
            
            Divider()
            
            HStack{
                Button{
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.body)
                }
                
                Button{
                    showSheet.toggle()
                } label: {
                    Image(systemName: "camera")
                        .font(.body)
                }
                .padding(.horizontal, 5)
                
                TextField("messagge", text: $vm.chatText)
                
                Button{
                    showKB = false
                    vm.onSend()
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.title2)
                }
            }
            .padding(10)
        }
        .frame(maxHeight: .infinity,alignment: .top)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .alert(errorMsg, isPresented: $showError, actions: {})
        .task {
            vm.chatID = self.chat_id
            fetchChatData()
        }
        .onChange(of: vm.chatID) { change in
            vm.fetchMessages()
        }
    }
    
    func fetchChatData(){
        Task{
            do{
                let chat = try await Firestore.firestore().collection("Chats").document(chat_id).getDocument(as: Chat.self)
                
                let job = try await Firestore.firestore().collection("Jobs").document(chat.jobId).getDocument(as: Job.self)
                
                
                await MainActor.run(body: {
                    jobInfo = job
                    isLoading = false
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
        })
    }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
