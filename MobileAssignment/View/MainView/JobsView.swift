//
//  JobsView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 25/6/2023.
//

import SwiftUI
import Firebase

struct JobsView: View {
    @State var createNewJob: Bool = false
    @State var recentJobs: [Job] = []
    
    @State var isFetchingData: Bool = true
    
    @State var chatAboutJob: Bool = false
    
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack{
                    if isFetchingData {
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
            .frame(maxHeight: .infinity,alignment: .center)
            .frame(maxWidth: .infinity,alignment: .center)
            .overlay(alignment: .bottomTrailing) {
                Button{
                    createNewJob.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(10)
                        .background(.black, in: Circle())
                }
                .padding(20)
            }
            .navigationTitle("Jobs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "message.circle")
                            .font(.title2)
                    }
                }
            }
            .refreshable {
                isFetchingData = true
                recentJobs = []
                await fetchJobs()
            }
            .task {
                guard recentJobs.isEmpty else{return}
                await fetchJobs()
            }
        }
        .fullScreenCover(isPresented: $createNewJob) {
            CreateJobView()
        }
        .onChange(of: createNewJob){newValue in
            Task{
                isFetchingData = true
                recentJobs = []
                await fetchJobs()
            }
            
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
            var query: Query!
            query = Firestore.firestore().collection("Jobs")
                .order(by: "createdDate", descending: true)
                .limit(to: 10)
            
            let docs = try await query.getDocuments()
            let fetchedJobs = docs.documents.compactMap {doc -> Job? in
                try? doc.data(as: Job.self)
            }
            
            await MainActor.run(body: {
                recentJobs = fetchedJobs
                isFetchingData = false
            })
        }catch {
            print(error.localizedDescription)
        }
    }
}

struct JobsView_Previews: PreviewProvider {
    static var previews: some View {
        JobsView()
    }
}
