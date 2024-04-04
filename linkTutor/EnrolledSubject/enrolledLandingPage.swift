//
//  enrolledLandingPage.swift
//  linkTutor
//
//  Created by Aditya Pandey on 29/03/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct enrolledLandingPage: View {
    var id : String
    var skillUid : String
    var skillOwnerDetailsUid : String
    var className: String
    var teacherUid: String

    @State private var isCopied = false
    @State private var startTimeString = ""
    @State private var endTimeString = ""
    @State private var showAlert = false
    
    @ObservedObject var studentViewModel = StudentViewModel.shared
    
    @State var showingUpdate = false
    @ObservedObject var teacherViewModel = TeacherViewModel.shared
    @ObservedObject var reviewViewModel = ReviewViewModel()
    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var skillViewModel = SkillViewModel()
    @State private var showDeleteAlert = false
    
    


    var body: some View {
        NavigationStack {
          
                if let skillType = skillViewModel.skillTypes.first(where: { $0.id == skillUid }) {
                    VStack {
                        if let detail = skillType.skillOwnerDetails.first(where: { $0.id == skillOwnerDetailsUid }) {
                            
                            
                            VStack {
                                VStack {
                                    // Header
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(detail.academy)")
                                                .font(AppFont.largeBold)

                                            if let teacherDetails = teacherViewModel.teacherDetails.first {
                                                Text("by \(teacherDetails.fullName)")
                                                    .font(AppFont.mediumReg)
                                            } else {
                                                Text("Loading...")
                                                    .font(AppFont.mediumReg)
                                            }
                                        }
                                        .padding(.horizontal)
                                        Spacer()
                                    }

                                    ScrollView(.vertical) {
                                        if !teacherViewModel.teacherDetails.isEmpty {
                                            // View content using teacherViewModel.teacherDetails
                                            if let teacherDetails = teacherViewModel.teacherDetails.first {
                                                // Rating and Review
                                                HStack {
                                                    let reviewsForSkillOwner = reviewViewModel.reviewDetails.filter { $0.teacherUid == teacherUid && $0.skillOwnerDetailsUid == skillOwnerDetailsUid }
                                                                                          
                                                    if !reviewsForSkillOwner.isEmpty {
                                                        let averageRating = reviewsForSkillOwner.reduce(0.0) { $0 + Double($1.ratingStar) } / Double(reviewsForSkillOwner.count)
                                                        
                                                        Text("\(averageRating, specifier: "%.1f") ⭐️")
                                                            .padding([.top, .bottom], 4)
                                                            .padding([.leading, .trailing], 12)
                                                            .background(Color.background)
                                                            .cornerRadius(10)
                                                        
                                                        Text("\(reviewsForSkillOwner.count) Review\(reviewsForSkillOwner.count == 1 ? "" : "s")")
                                                            .font(AppFont.smallReg)
                                                            .foregroundColor(.black)
                                                    } else {
                                                        Text("No Review")
                                                            .font(AppFont.smallReg)
                                                            .foregroundColor(.black)
                                                    }
                                                    Spacer()
                                                }

                                                // Enroll button
                                              
                                                HStack {
                                                    Button(action: {
                                                        showDeleteAlert.toggle()
                                                
                                                    }) {
                                                        Text("Unenroll")
                                                            .font(AppFont.actionButton)
                                                            .foregroundColor(.white)
                                                    }
                                                    .frame(minWidth: 90, minHeight: 30)
                                                    .background(Color.red)
                                                    .cornerRadius(8)
                                                    .alert(isPresented: $showDeleteAlert) {
                                                        Alert(
                                                            title: Text("Unenroll from class"),
                                                            message: Text("Are you sure?"),
                                                            primaryButton: .destructive(Text("Delete")) {
                                                                Task {
                                                                    RequestListViewModel().deleteEnrolled(id: id)
                                                                }
                                                            },
                                                            secondaryButton: .cancel()
                                                        )
                                                    }
                                                    Spacer()
                                                }
                                                
                                             
                                                QuickInfoCard(tutorAddress: "\(teacherDetails.city)", startTime: detail.endTime , endTime: detail.endTime, tutionFee: detail.price )
                                                                                       .padding([.top, .bottom], 10)
                                              
                                                // QuickInfoBox
                                              
                                               //Phone fill , message fill code
                                                HStack {
                                                    HStack {
                                                        Image(systemName: "phone.fill")
                                                            .font(.system(size: 15))

                                                        Text(String("\(teacherDetails.phoneNumber)"))
                                                            .font(AppFont.actionButton)
                                                    }
                                                    .padding([.top, .bottom], 6)
                                                    .padding([.leading, .trailing], 12)
                                                    .background(Color.phoneAccent)
                                                    .foregroundStyle(Color.black)
                                                    .cornerRadius(50)
                                                    .onTapGesture {
                                                        let phoneNumberString = "\(teacherDetails.phoneNumber)"
                                                        UIPasteboard.general.string = phoneNumberString
                                                        isCopied = true
                                                    }
                                                    .alert(isPresented: $isCopied) {
                                                        Alert(title: Text("Copied!"), message: Text("Phone number copied to clipboard."), dismissButton: .default(Text("OK")))
                                                    }

                                                    HStack {
                                                        Image(systemName: "message.fill")
                                                            .font(.system(size: 15))
                                                        Text("iMessage")
                                                            .font(AppFont.actionButton)
                                                    }
                                                    .padding([.top, .bottom], 4)
                                                    .padding([.leading, .trailing], 12)
                                                    .background(Color.messageAccent)
                                                    .foregroundStyle(Color.black)
                                                    .cornerRadius(50)
                                                 
                                                    Spacer()
                                                }
                                                .padding([.top, .bottom], 10)

                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        Text("Mode")
                                                            .font(AppFont.mediumSemiBold)
                                                            .padding(.bottom, 5)
                                                            .padding(.top)
                                                        VStack {
                                                            if detail.mode == "both" {
                                                                HStack {
                                                                    Image(systemName: "checkmark")
                                                                        .font(.system(size: 20))
                                                                    Text("Online")
                                                                        .font(AppFont.smallReg)
                                                                        .foregroundColor(.gray)
                                                                    Spacer()
                                                                }.padding(5)
                                                                HStack {
                                                                    Image(systemName: "checkmark")
                                                                        .font(.system(size: 20))
                                                                    Text("Offline")
                                                                        .font(AppFont.smallReg)
                                                                        .foregroundColor(.gray)
                                                                    Spacer()
                                                                }.padding(5)
                                                            }
                                                            else{
                                                                HStack {
                                                                    Image(systemName: "checkmark")
                                                                        .font(.system(size: 20))
                                                                    Text("\(detail.mode)")
                                                                        .font(AppFont.smallReg)
                                                                        .foregroundColor(.gray)
                                                                    Spacer()
                                                                }.padding(5)
                                                            }
                                                        }
                                                    }
                                                    Spacer()
                                                }

                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        Text("Reviews")
                                                            .font(AppFont.mediumSemiBold)
                                                            .padding(.bottom, 5)
                                                            .padding(.top)

                                                        ForEach(reviewViewModel.reviewDetails.filter { $0.skillUid == "\(skillUid)" && $0.teacherUid == "\(teacherUid)" && $0.skillOwnerDetailsUid == "\(skillOwnerDetailsUid)" }) { teacherDetail in
                                                            
                                                            if let formattedDate = formatDate(teacherDetail.time) {
                                                                reviewCard(reviewRating: teacherDetail.ratingStar , review: "\(teacherDetail.comment)", time: "\(formattedDate)")
                                                            }
                                                          
                                                        }// End of For loop
                                                    }
                                                    .padding([.top, .bottom], 10)
                                                    Spacer()
                                                }
                                                Spacer()
                                            } else {
                                                Text("Loading...")
                                                    .font(AppFont.mediumReg)
                                            }
                                        } else {
                                            Text("Loading...")
                                                .padding()
                                        }
                                    }
                                    .padding()
                                }
                                .background(Color.background)
                                .onAppear {

                                    DispatchQueue.main.async {
                                        Task {
                                            await teacherViewModel.fetchTeacherDetailsByID(teacherID: teacherUid)
                                        }
                                    }
                                }
                            }//End of VStack
                            
                        }}
                    .onAppear() {
                        skillViewModel.fetchSkillOwnerDetails(for: skillType)
                    }
                } //End of both if let statement of skillViewModel
         
        }//End of navigation Stack
    }
    
    func formatDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY" // Date format: dayOfMonth month
        return dateFormatter.string(from: date)
    }
    
    private func openMessagesApp(withPhoneNumber phoneNumber: String) {
            let smsUrlString = "sms:\(phoneNumber)"
            guard let smsUrl = URL(string: smsUrlString) else { return }
            UIApplication.shared.open(smsUrl)
        }
}




import SwiftUI
import Firebase

struct QuickInfoCard: View {
    var tutorAddress: String
    var startTime: Timestamp
    var endTime: Timestamp
    var tutionFee: Int
    
    // DateFormatter to format Timestamp to Time
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy" // Format: "25 January 2024"
        return formatter
    }()
    
    // DateFormatter to format Timestamp to Time
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Format: "3:30 PM"
        return formatter
    }()
    
    var body: some View {
        VStack {
            // Address
            VStack(alignment: .leading) {
                Text("Address")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "location.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                    Text("\(tutorAddress)")
                        .font(.subheadline)
                    Spacer()
                }
            }
            .padding(.bottom, 5)
            
            // Timing
            VStack(alignment: .leading) {
                Text("Enrolled Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text(formatDate(startTime)!)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            .padding(.bottom, 5)
            
            // Fee
            VStack(alignment: .leading) {
                Text("Fee")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text("₹\(tutionFee) /month")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 180)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // Function to format Timestamp to Date
    func formatDate(_ timestamp: Timestamp) -> String? {
        let date = timestamp.dateValue()
        return dateFormatter.string(from: date)
    }
}
