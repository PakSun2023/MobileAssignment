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
    
    @AppStorage("user_UID") var user_UID: String = ""
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
                    
                } label: {
                    Image(systemName: "message")
                        .font(.body)
                }
            }
        })
        .padding(.horizontal, 10)
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
}
