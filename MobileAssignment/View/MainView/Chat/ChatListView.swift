//
//  ChatListView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 27/6/2023.
//

import SwiftUI
import Firebase

struct ChatListView: View {
    @State var recentChats: [Chat] = []
    
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = true
    
    @State var showChatView: Bool = false
    
    @AppStorage("chat_id") var chat_id: String = ""
    @AppStorage("user_UID") var user_UID: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack{
                    if isLoading {
                        ProgressView()
                            .padding(.top, 25)
                    } else {
                        if recentChats.isEmpty {
                            Text("No Chats Found")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }else {
                            Chats()
                        }
                    }
                }
                .padding(20)
            }
            .frame(maxHeight: .infinity,alignment: .center)
            .frame(maxWidth: .infinity,alignment: .center)
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", role: .destructive) {
                        dismiss()
                    }
                    .font(.callout)
                    .foregroundColor(.black)
                }
                
            }
            .refreshable {
                isLoading = true
                recentChats = []
                await fetchChats()
            }
            .task {
                guard recentChats.isEmpty else{return}
                await fetchChats()
            }
        }
        .fullScreenCover(isPresented: $showChatView) {
            ChatView()
        }
    }
    
    
    @ViewBuilder
    func Chats() -> some View {
        ForEach(recentChats) {chat in
            HStack{
                VStack(alignment: .leading) {
                    Text(chat.jobTitle)
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack(spacing: 8) {
                        Text("Chat with:")
                        if user_UID == chat.jobOwnerId {
                            Text(chat.jobRequest)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        } else {
                            Text(chat.jobOwner)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        }
                    }
                    
                    
                }
                
                Spacer()
                
                Button{
                    chat_id = chat.id!
                    showChatView = true
                } label: {
                    Image(systemName: "message")
                        .font(.body)
                }
            }
            
            Divider()
        }
    }
    
    func fetchChats() async {
        do {
            var query: Query!
            query = Firestore.firestore().collection("Chats")
                .whereField("jobRequestId", isEqualTo: self.user_UID)
            
            let docs = try await query.getDocuments()
            let fetchedChats = docs.documents.compactMap {doc -> Chat? in
                try? doc.data(as: Chat.self)
            }
            
            var query2: Query!
            query2 = Firestore.firestore().collection("Chats")
                .whereField("jobOwnerId", isEqualTo: self.user_UID)
            
            let docs2 = try await query2.getDocuments()
            let fetchedChats2 = docs2.documents.compactMap {doc -> Chat? in
                try? doc.data(as: Chat.self)
            }
            
            await MainActor.run(body: {
                recentChats = fetchedChats
                recentChats.append(contentsOf: fetchedChats2)
                isLoading = false
            })
        }catch {
            print(error.localizedDescription)
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
