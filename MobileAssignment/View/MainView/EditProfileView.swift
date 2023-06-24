//
//  EditProfileView.swift
//  MobileAssignment
//
//  Created by KayTee Chan on 19/6/2023.
//

import SwiftUI
import Firebase

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
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
                    dismiss()
                } label: {
                    Text("Update")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(.black, in: Capsule())
                }
            }
            .padding(.horizontal)
            
            Divider()
        }
        .frame(maxHeight: .infinity,alignment: .top)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
