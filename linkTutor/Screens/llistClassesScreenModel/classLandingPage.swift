import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct classLandingPage: View {
    var teacherUid: String
    var academy: String
    var skillUid: String
    var skillOwnerUid: String
    var className: String
    var startTime : Date
    var endTime : Date
    var week : [String]
    var mode : String
    var teacherDetail: TeacherDetails
    var price : Int
    var skillOnwerDetailsUid : String

  

   
    //This variable to automatically refresh page

    @State private var isCopied = false
    @State private var showAlert = false
    
    @ObservedObject var studentViewModel = StudentViewModel.shared
    
    @State var showingUpdate = false
    @ObservedObject var teacherViewModel = TeacherViewModel.shared
    @ObservedObject var reviewViewModel = ReviewViewModel()
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    


    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(academy)")
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

                    ScrollView(.vertical, showsIndicators: false) {
                        if !teacherViewModel.teacherDetails.isEmpty {
                            // View content using teacherViewModel.teacherDetails
                            if let teacherDetails = teacherViewModel.teacherDetails.first {
                                // Rating and Review
                                HStack {
                                    let reviewsForSkillOwner = reviewViewModel.reviewDetails.filter { $0.teacherUid == teacherUid && $0.skillOwnerDetailsUid == skillOnwerDetailsUid }
                                                                          
                                    if !reviewsForSkillOwner.isEmpty {
                                        let averageRating = reviewsForSkillOwner.reduce(0.0) { $0 + Double($1.ratingStar) } / Double(reviewsForSkillOwner.count)
                                        
                                        Text("\(averageRating, specifier: "%.1f") ⭐️")
                                            .padding([.top, .bottom], 4)
                                            .padding([.leading, .trailing], 12)
                                            .background(Color.elavated)
                                            .cornerRadius(50)
                                        
                                        Text("\(reviewsForSkillOwner.count) Review\(reviewsForSkillOwner.count == 1 ? "" : "s")")
                                            .font(AppFont.smallReg)
                                            .foregroundColor(.black).opacity(0.6)
                                    } else {
                                        Text("No Review")
                                            .font(AppFont.smallReg)
                                            .foregroundColor(.black)
                                    }
                                    Spacer()
                                }
                                .padding(.leading, 5)

                                // Enroll button
                              
                                HStack {
                                   //Enroll button link
                                    
//                                    NavigationLink(destination: requestConfirmation(), isActive: $showingUpdate) {
                                        Button(action: {
                                            showAlert.toggle()
                                              print("Enrollment action")

                                                let userId = Auth.auth().currentUser?.uid
                                                Task {
                                                    await studentViewModel.fetchStudentDetailsByID(studentID: userId!)
                                             

                                                // Wait for userDetails to be populated
                                                while studentViewModel.userDetails.isEmpty {
                                                    await Task.sleep(100) // Adjust the sleep duration as needed
                                                }

                                                // Now userDetails should have at least one element
                                                if let userDetails = studentViewModel.userDetails.first {
                                                    do {
                                                        try await viewModel.addEnrolledStudent(teacherName: teacherDetails.fullName,
                                                                                                skillOwnerDetailsUid: skillOwnerUid,
                                                                                                studentName: userDetails.fullName,
                                                                                                studentUid: userId ?? "",
                                                                                                studentNumber: userDetails.phoneNumber,
                                                                                                requestAccepted: 0,
                                                                                                requestSent: 1,
                                                                                                className: className,
                                                                                                teacherNumber: teacherDetails.phoneNumber,
                                                                                                teacherUid: teacherUid ,
                                                                                               skillUid:  skillUid,
                                                                                               startTime: startTime,
                                                                                               week: week
                                                                                               
                                                                                              
                                                        )
                                                      
                                                    } catch {
                                                        print("Error adding enrolled student: \(error.localizedDescription)")
                                                    }
                                                } else {
                                                    print("No user details fetched yet")
                                                }
                                            }
                                        }) {
                                            Text("Enroll now")
                                                .font(AppFont.mediumReg)
                                                .foregroundColor(.white)
                                                .padding(10)
                                                .padding([.leading, .trailing], 20)
                                        }
                                        .background(Color.accent)
                                        .cornerRadius(20)
                                        .padding([.top, .bottom], 10)
                                        .padding(.leading, 5)
                                        .alert(isPresented: $showAlert) {
                                                    Alert(
                                                        title: Text("Request Sent"),
                                                        message: Text("A request has been sent\nPlease wait for any updates"),
                                                        dismissButton: .default(Text("Okay"))
                                                    )
                                                }
//                                    }
                                    Spacer()
                                }
                                
                               
                                // QuickInfoBox
                                quickInfoCard(tutorAddress: "\(teacherDetails.city)".capitalized, startTime: startTime, endTime: endTime , tutionFee: price )
                                    .padding([.top, .bottom], 10)
                              
                              
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
//                                    .onTapGesture {
//                                        if let phoneURL = URL(string: "tel:\(teacherDetails.phoneNumber)") {
//                                                        UIApplication.shared.open(phoneURL)
//                                                    }
//                                                }
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
                                    .padding([.top, .bottom], 6)
                                    .padding([.leading, .trailing], 12)
                                    .background(Color.messageAccent)
                                    .foregroundStyle(Color.black)
                                    .cornerRadius(50)
                                    .onTapGesture {
                                        openMessagesApp(withPhoneNumber: String(teacherDetails.phoneNumber))
                                    }
                                    Spacer()
                                }
                                .padding([.top, .bottom], 10)
                                .padding(.leading, 5)

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Mode")
                                            .font(AppFont.mediumSemiBold)
                                            .padding(.bottom, 5)
                                            .padding(.top)
                                        VStack {
                                            if mode == "both" {
                                                HStack {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 20))
                                                        .foregroundStyle(Color.black).opacity(0.6)
                                                    Text("Online")
                                                        .font(AppFont.smallReg)
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                }.padding(5)
                                                HStack {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 20))
                                                        .foregroundStyle(Color.black).opacity(0.6)
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
                                                        .foregroundStyle(Color.black).opacity(0.6)
                                                    Text("\(mode)".capitalized)
                                                        .font(AppFont.smallReg)
                                                        .foregroundColor(.black)
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

                                        ForEach(reviewViewModel.reviewDetails.filter { $0.skillUid == "\(skillUid)" && $0.teacherUid == "\(teacherUid)" && $0.skillOwnerDetailsUid == "\(skillOwnerUid)" }) { teacherDetail in
                                            
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
                    } //scroll end
                    .padding([.horizontal, .bottom])
                }
                .background(Color.background)
                .onAppear {
              
                    DispatchQueue.main.async {
                        Task {
                            await teacherViewModel.fetchTeacherDetailsByID(teacherID: teacherUid)
                        }
                    }
                }
            }//vstack end
            .edgesIgnoringSafeArea(.bottom)
        }
        
      
       
      
    }
    
        
       

    func formatDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY" // Date format: dayOfMonth month
        return dateFormatter.string(from: date)
    }
    
    func formatDateTime(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // Date format: dayOfMonth month year hour:minute AM/PM
        return dateFormatter.string(from: date)
    }


    
    private func openMessagesApp(withPhoneNumber phoneNumber: String) {
            let smsUrlString = "sms:\(phoneNumber)"
            guard let smsUrl = URL(string: smsUrlString) else { return }
            UIApplication.shared.open(smsUrl)
        }
    
}




