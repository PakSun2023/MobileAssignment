//
//  JobsView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 25/6/2023.
//

import SwiftUI

struct JobsView: View {
    @State var createNewJob: Bool = false
    var body: some View {
        VStack{
            HStack{
                Spacer()
                
                Button{
                    createNewJob.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(5)
                        .background(.black, in: Circle())
                }
                .padding(2)
            }
            .padding(.horizontal)
            
            Divider()
        }
        .frame(maxHeight: .infinity,alignment: .top)
        .fullScreenCover(isPresented: $createNewJob) {
            CreateJobView()
        }
    }
    
}

struct JobsView_Previews: PreviewProvider {
    static var previews: some View {
        JobsView()
    }
}
