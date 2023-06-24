//
//  CreateJobView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 24/6/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import PhotosUI

struct CreateJobView: View {
    //    var onCreate: (Job) -> ()
    
    @State var jobTitle: String = ""
    @State var jobDescriptioon: String = ""
    @State var jobImagesData: [Data] = []
    
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    @State var isLoading: Bool = false
    @State var showImagePicker: Bool = false
    @State var imageItem: PhotosPickerItem?
    @FocusState var showKB: Bool
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("is_login") var is_login: Bool = false
    @AppStorage("user_name") var user_name: String = ""
    @AppStorage("user_email") var user_email: String = ""
    @AppStorage("user_UID") var user_UID: String = ""
    var body: some View {
        VStack{
            HStack{
                Button("Cancel", role: .destructive) {
                    dismiss()
                }
                .font(.callout)
                .foregroundColor(.black)
                
                Spacer()
                
                Button{
                    createJob()
                } label: {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(.black, in: Capsule())
                }
                .opacity(jobTitle == "" || jobDescriptioon == "" ? 0.7 : 1)
                .disabled(jobTitle == "" || jobDescriptioon == "")
            }
            .padding(.horizontal)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    HStack{
                        Text("Job Title:")
                        TextField("Post a New Job?", text: $jobTitle, axis: .vertical)
                            .focused($showKB)
                    }
                    
                    HStack{
                        TextField("Job Detail?", text: $jobDescriptioon, axis: .vertical)
                            .focused($showKB)
                    }
                    .padding(.top)
                    
                    
                    if !jobImagesData.isEmpty {
                        ForEach(0..<jobImagesData.count, id: \.self) { index in
                            GeometryReader{
                                let size = $0.size
                                Image(uiImage: UIImage(data: jobImagesData[index])!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size.width, height: size.height)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            jobImagesData.remove(at: index)
                                        } label: {
                                            Image(systemName: "trash")
                                                .fontWeight(.bold)
                                                .tint(.red)
                                        }
                                        .padding(5)
                                    }
                            }
                            .clipped()
                            .frame(height: 200)
                        }
                    }
                }
                .padding(10)
            }
            
            Divider()
            
            HStack{
                Button{
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.body)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                
                Button("Done"){
                    showKB = false
                }
            }
            .padding(10)
        }
        .frame(maxHeight: .infinity,alignment: .top)
        .photosPicker(isPresented: $showImagePicker, selection: $imageItem, matching: .images)
        .onChange(of: imageItem) {newValue in
            if let newValue {
                Task{
                    do {
                        if let imageData = try await newValue.loadTransferable(type: Data.self),
                           let image = UIImage(data: imageData),
                           let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                            await MainActor.run(body: {
                                jobImagesData.append(compressedImageData)
                                imageItem = nil
                            })
                        }
                    } catch {
                        print("debug: ", error)
                    }
                    
                }
            }
        }
        .alert(errorMsg, isPresented: $showError, actions: {})
        .overlay{
            LoadingView(show: $isLoading)
        }
    }
    
    func createJob() {
        isLoading = true
        showKB = false
        Task{
            do{
                var imagesUrl: [URL] = []
                if !jobImagesData.isEmpty{
                    for (index, imageData) in jobImagesData.enumerated() {
                        let referenceId = "\(user_UID)\(Date())\(index)"
                        let storageRef = Storage.storage().reference().child("Job_Images").child(referenceId)
                        let _ = try await storageRef.putDataAsync(imageData)
                        let imageUrl = try await storageRef.downloadURL()
                        
                        imagesUrl.append(imageUrl)
                    }
                }
                
                let job = Job(title: jobTitle, description: jobDescriptioon, imagesURL: imagesUrl, username: user_name, userUID: user_UID)
                let _ = try Firestore.firestore().collection("Jobs").addDocument(from: job, completion: {
                    error in
                    if error == nil {
                        isLoading = false
                        dismiss()
                    }
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

struct CreateJobView_Previews: PreviewProvider {
    static var previews: some View {
        CreateJobView()
    }
}
