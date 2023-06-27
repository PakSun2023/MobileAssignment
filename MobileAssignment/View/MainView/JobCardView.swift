//
//  JobCardView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 25/6/2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct JobCardView: View {
    var job: Job
    var onDelete: () -> ()
    
    @State var showChatView: Bool = false
    
    @AppStorage("chat_id") var chat_id: String = ""
    @AppStorage("user_UID") var user_UID: String = ""
    @AppStorage("user_name") var user_name: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(job.title)
                .font(.callout)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(job.description)
                .textSelection(.enabled)
            
            if !job.imagesURL!.isEmpty{
                ForEach(0..<job.imagesURL!.count, id: \.self) { index in
                    GeometryReader{
                        let size = $0.size
                        WebImage(url: job.imagesURL![index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
            }
            
            Text(job.createdDate.formatted(date:.numeric, time: .shortened))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .overlay(alignment: .topTrailing, content: {
            if job.userUID == user_UID {
                Menu{
                    Button("Delete", role: .destructive, action: deleteJob)
                    if job.status != jobStatus.completed {
                        Button("Completed", role: .none, action: completeJob)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(5)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            } else {
                Button{
                    handleChat()
                } label: {
                    Image(systemName: "plus.message")
                        .font(.body)
                }
            }
        })
        .padding(.horizontal, 10)
        .fullScreenCover(isPresented: $showChatView) {
            ChatView()
        }
    }
    
    func deleteJob(){
        Task{
            do{
                guard let jobID = job.id else{return}
                try await Firestore.firestore().collection("Jobs").document(jobID).delete()
                onDelete()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func completeJob(){
        Task{
            do{
                guard let jobID = job.id else{return}
                try await Firestore.firestore().collection("Jobs").document(jobID).updateData(["status": jobStatus.completed])
                onDelete()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func handleChat() {
        Task{
            do{
                guard let jobID = job.id else{return}
                let jobName = job.title
                let jobOwnerID = job.userUID
                let jobOwnerName = job.username
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                
                var query: Query!
                query = Firestore.firestore().collection("Chats")
                    .whereField("jobId", isEqualTo: jobID)
                    .whereField("jobRequestId", isEqualTo: userUID)
                
                let docs = try await query.getDocuments()
                
                if docs.isEmpty {
                    let newChatData = ["jobId": jobID, "jobTitle": jobName, "jobOwnerId": jobOwnerID, "jobOwner": jobOwnerName, "jobRequestId": userUID, "jobRequest": self.user_name]
                    
                    let newChat = try Firestore.firestore().collection("Chats").addDocument(from: newChatData)
                    
                    chat_id = newChat.documentID
                } else {
                    chat_id = docs.documents[0].documentID
                }
                
                if chat_id != "" {
                    showChatView = true
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
