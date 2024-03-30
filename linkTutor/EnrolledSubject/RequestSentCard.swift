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
    var skillUid : String
    var skillOwnerDetailsUid : String
    var teacherUid: String

    
    @State var showingUpdateCourse = false
//    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var viewModel = RequestListViewModel()
    @State private var showDeleteAlert = false
    
    var body: some View{
        NavigationStack{
           
                VStack{
                    
                    NavigationLink(destination : requestSentLandingPage(id: id, skillUid: skillUid, skillOwnerDetailsUid: skillOwnerDetailsUid, className: className, teacherUid: teacherUid)){
                        HStack{
                            VStack(alignment: .leading){
                                Text("\(className)")
                                    .font(AppFont.mediumSemiBold)
                                
                                Text("\(teacherName)")
                                    .font(AppFont.smallReg)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                              
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
                                            viewModel.deleteEnrolled(id: id)
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 70)
                .padding()
                .background(Color.elavated)
                .foregroundColor(.black)
                .cornerRadius(10)
            
        }
    }
}
    
#Preview {
    RequestSentCard(teacherName: "Obama", phoneNumber: 1234567890 , id: "1", className: "Science", skillUid: "skillUid" , skillOwnerDetailsUid: "skillOwnerDetailsUid" , teacherUid: "teacherUid")
}
