//
//  RequestSentCard.swift
//  linkTutor
//
//  Created by Aditya Pandey on 13/03/24.
//

import SwiftUI

struct RequestSentCard: View {
    var teacherName : String
    var phoneNumber : Int
    var id : String
    var className : String
    @State var showingUpdateCourse = false
//    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var viewModel = RequestListViewModel()
    @State private var showDeleteAlert = false
    
    var body: some View{
        NavigationStack{
            VStack{
                HStack{
                    VStack(alignment: .leading){
                        Text("\(className)")
                            .font(AppFont.mediumSemiBold)
                        
                        Text("\(teacherName)")
                            .font(AppFont.smallReg)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Delete button action
//                        Task {
//                            await viewModel.deleteEnrolled(id: id)
//                        }
                        showDeleteAlert.toggle()
                    }) {
                        Text("Delete")
                            .font(AppFont.actionButton)
                            .frame(minWidth: 90, minHeight: 30)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text("Delete request"),
                                    message: Text("Are you sure?"),
                                    primaryButton: .destructive(Text("Delete")) {
                                        Task {
                                            await viewModel.deleteEnrolled(id: id)
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 70)
            .padding()
            .background(Color.accent)
            .foregroundColor(.black)
            .cornerRadius(10)
        }
    }
}
    
#Preview {
    RequestSentCard(teacherName: "Obama", phoneNumber: 1234567890 , id: "1", className: "Science")
}
