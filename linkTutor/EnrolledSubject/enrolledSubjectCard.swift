//
//  enrolledSubjectCard.swift
//  linkTutor
//
//  Created by Aditya Pandey on 13/03/24.
//

import SwiftUI


struct enrolledSubjectCard: View {
    var teacherName: String
    var phoneNumber: Int
    var id: String
    var className: String
    var skillOwnerDetailsUid: String
    var teacherUid: String
    var skillUid: String
    
    @State var isButtonClicked = false
    @ObservedObject var viewModel = RequestListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(className)
                            .font(AppFont.mediumSemiBold)
                        
                        Text(teacherName)
                            .font(AppFont.smallReg)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    VStack {
//                        NavigationLink(
//                            isActive: $isButtonClicked
//                        ) {
                            Button(action:{
                                isButtonClicked = true
                            }) {
                                Text("Add review")
                                    .font(AppFont.actionButton)
                                    .foregroundColor(.white)
                            }
                            .sheet(isPresented: $isButtonClicked) {
                                RatingFormView(className: className,
                                                            skillOwnerDetailsUId: skillOwnerDetailsUid,
                                                           teacherUid: teacherUid,
                                                           skillUid: skillUid)
                            }
                            .frame(minWidth: 90, minHeight: 30)
                            .background(Color.elavated.opacity(0.7))
                            .cornerRadius(8)
//                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.deleteEnrolled(id: id)
                            }
                        }) {
                            Text("Unenroll")
                                .font(AppFont.actionButton)
                                .foregroundColor(.white)
                        }
                        .frame(minWidth: 90, minHeight: 30)
                        .background(Color.red)
                        .cornerRadius(8)
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

struct EnrolledSubjectCard_Previews: PreviewProvider {
    static var previews: some View {
        enrolledSubjectCard(teacherName: "Teacher Name",
                            phoneNumber: 1234567890,
                            id: "ID",
                            className: "Class Name",
                            skillOwnerDetailsUid: "Skill Owner Details UID",
                            teacherUid: "Teacher UID",
                            skillUid: "Skill UID")
    }
}
