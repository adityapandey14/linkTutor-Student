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
    var startTime : Timestamp
    var endTime : Timestamp
    var week : [String]
    var mode : String
    var teacherDetail: TeacherDetails
    var price : Int
    

  

   
    //This variable to automatically refresh page

    @State private var isCopied = false
    @State private var startTimeString = ""
    @State private var endTimeString = ""
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

                    ScrollView(.vertical) {
                        if !teacherViewModel.teacherDetails.isEmpty {
                            // View content using teacherViewModel.teacherDetails
                            if let teacherDetails = teacherViewModel.teacherDetails.first {
                                // Rating and Review
                                HStack {
                                    Text("4.0 ⭐️")
                                        .font(AppFont.smallReg)
                                        .padding([.top, .bottom], 4)
                                        .padding([.leading, .trailing], 12)
                                        .background(Color.elavated)
                                        .cornerRadius(10)
                                    Text("40 reviews")
                                        .font(AppFont.smallReg)
//                                        .padding(.leading)
                                        .foregroundColor(.white).opacity(0.7)
                                    Spacer()
                                }

                                // Enroll button
                              
                                HStack {
                                   //Enroll button link
                                    
//                                    NavigationLink(destination: requestConfirmation(), isActive: $showingUpdate) {
                                        Button(action: {
                                            showAlert.toggle()
                                              print("Enrollment action")

                                                var userId = Auth.auth().currentUser?.uid
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
                                                        showingUpdate = true
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
                                                .foregroundColor(.black)
                                                .padding(10)
                                                .padding([.leading, .trailing], 20)
                                        }
                                        .background(Color.accent)
                                        .cornerRadius(20)
                                        .padding([.top, .bottom], 10)
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
                                
                             
                                    quickInfoCard(tutorAddress: "\(teacherDetails.city)", startTime: startTimeString , endTime: endTimeString, tutionFee: price )
                                                                       .padding([.top, .bottom], 10)
                              
                                // QuickInfoBox
                              
                               //Phone fill , message fill code
                                HStack {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 17))

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
                                            .font(.system(size: 17))
                                        Text("iMessage")
                                            .font(AppFont.actionButton)
                                    }
                                    .padding([.top, .bottom], 4)
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
                                                    Text("\(mode)")
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
                    }
                    .padding()
                }
                .background(Color.background)
                .onAppear {
                    fetchTimes()
                    DispatchQueue.main.async {
                        Task {
                            await teacherViewModel.fetchTeacherDetailsByID(teacherID: teacherUid)
                        }
                    }
                }
            }
        }
        
        .onReceive(teacherViewModel.$teacherDetails) { _ in
            fetchTimes() // Call fetchTimes() when teacherDetails changes
        }
       
      
    }
    
        
       

    func formatDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY" // Date format: dayOfMonth month
        return dateFormatter.string(from: date)
    }
    
    private func fetchTimes() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            let startDate = startTime.dateValue()
            let endDate = endTime.dateValue()

            startTimeString = dateFormatter.string(from: startDate)
            endTimeString = dateFormatter.string(from: endDate)
        }
    
    private func openMessagesApp(withPhoneNumber phoneNumber: String) {
            let smsUrlString = "sms:\(phoneNumber)"
            guard let smsUrl = URL(string: smsUrlString) else { return }
            UIApplication.shared.open(smsUrl)
        }
    
}




//HStack{
//    VStack(alignment: .leading){
//        Text("Mode")
//            .font(AppFont.smallSemiBold)
//            .padding(.bottom, 5)
//        VStack{
//            HStack{
//                Image(systemName: "checkmark")
//                    .font(.system(size: 20))
//                Text("Classical Piano")
//                    .font(AppFont.smallReg)
//                    .foregroundColor(.gray)
//                Spacer()
//            }
//            .padding(5)
//            HStack{
//                Image(systemName: "checkmark")
//                    .font(.system(size: 20))
//                Text("Hindustani")
//                    .font(AppFont.smallReg)
//                    .foregroundColor(.gray)
//                Spacer()
//            }.padding(5)
//            HStack{
//                Image(systemName: "checkmark")
//                    .font(.system(size: 20))
//                Text("Carnatic")
//                    .font(AppFont.smallReg)
//                    .foregroundColor(.gray)
//                Spacer()
//            }.padding(5)
//        }
//    }
//    Spacer()
//}
//.padding([.top,.bottom], 10)

















//
//struct classLandingPage: View{
//
//  //  @StateObject var viewModel = listClassesScreenModel()
//    var teacherUid : String
//    var academy : String
//    let teacherViewModel = TeacherViewModel.shared
//
//
//
//
//    var body: some View{
//        if let teacherDetails = teacherViewModel.selectedTeacherDetails {
//
//        ZStack{
//
//            VStack{
//                //Header
//
//                HStack{
//                    VStack(alignment: .leading){
//                        Text("\(academy)")
//                            .font(AppFont.largeBold)
//                        Text("by \(teacherDetails.fullName)")
//                            .font(AppFont.mediumReg)
//                    }
//                    Spacer()
//                }
//
//
//                ScrollView(.vertical){
//
//                    //rating & review count
//                    HStack{
//                        Text("4.0 ⭐️")
//                            .font(AppFont.smallReg)
//                            .padding([.top, .bottom], 4)
//                            .padding([.leading, .trailing], 8)
//                            .foregroundStyle(Color.black)
//                            .background(.white)
//                            .cornerRadius(50)
//                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 12)
//                        Text("40 reviews")
//                            .font(AppFont.smallReg)
//                            .padding(.leading)
//                            .foregroundColor(.gray)
//                        Spacer()
//                    }
//
//                    //enroll button
//                    HStack{
//                        Button(action: {
//                            print("Enrollment action")
//                        }) {
//                            Text("Enroll now")
//                                .font(AppFont.mediumReg)
//                                .foregroundColor(.black)
//                                .padding(10)
//                                .padding([.leading, .trailing], 20)
//                        }
//                        .background(Color.accent)
//                        .cornerRadius(20)
//                        .padding([.top,.bottom], 10)
//
//                        Spacer()
//                    }
//
//                    //quickInfoBox
//                    quickInfoCard(tutorAddress: "\(teacherDetails.city)" , tutionDays: "\(30)", tutionTiming: "4-5 pm", tutionFee: 2000)
//                        .padding([.top,.bottom], 10)
//
//
//                    //phone and iMessage option
//                    HStack{
//                        HStack{
//                            Image(systemName: "phone.fill")
//                                .font(.system(size: 17))
//                            Text("\(teacherDetails.tutorPhone)")
//                                .font(AppFont.actionButton)
//                        }
//                        .padding([.top, .bottom], 6)
//                        .padding([.leading, .trailing], 12)
//                        .background(Color.phoneAccent)
//                        .foregroundStyle(Color.black)
//                        .cornerRadius(50)
//
//                        HStack{
//                            Image(systemName: "message.fill")
//                                .font(.system(size: 17))
//                            Text("iMessage")
//                                .font(AppFont.actionButton)
//                        }
//                        .padding([.top, .bottom], 4)
//                        .padding([.leading, .trailing], 12)
//                        .background(Color.messageAccent)
//                        .foregroundStyle(Color.black)
//                        .cornerRadius(50)
//                        Spacer()
//                    }
//                    .padding([.top,.bottom], 10)
//
//                    //about section
//                    HStack{
//                        VStack(alignment: .leading){
//                            Text("About")
//                                .font(AppFont.smallSemiBold)
//                                .padding(.bottom, 5)
//                            Text("\(teacherDetails.aboutParagraph)")
//                                .font(AppFont.smallReg)
//                                .foregroundColor(.gray)
//                        }
//                        .padding([.top,.bottom], 10)
//                        Spacer()
//                    }
//
//                    //Mode
//                    HStack{
//                        VStack(alignment: .leading){
//                            Text("Mode")
//                                .font(AppFont.smallSemiBold)
//                                .padding(.bottom, 5)
//                            VStack{
//                                HStack{
//                                    Image(systemName: "checkmark")
//                                        .font(.system(size: 20))
//                                    Text("Online")
//                                        .font(AppFont.smallReg)
//                                        .foregroundColor(.gray)
//                                    Spacer()
//                                }.padding(5)
//                                HStack{
//                                    Image(systemName: "checkmark")
//                                        .font(.system(size: 20))
//                                    Text("Offline")
//                                        .font(AppFont.smallReg)
//                                        .foregroundColor(.gray)
//                                    Spacer()
//                                }.padding(5)
//                            }
//                        }
//                        Spacer()
//                    } .onAppear {
//                        teacherViewModel.fetchTeacherDetailsByID(teacherID: teacherUid)
//                    }
//                }
//                    .padding([.top,.bottom], 10)
//
//                    //Offering Classes
//
//
//                    //Reviews
//                    HStack{
//                        VStack(alignment: .leading){
//                            Text("Reviews")
//                                .font(AppFont.smallSemiBold)
//                                .padding(.bottom, 5)
//                            reviewCard(reviewRating: "⭐️⭐️⭐️⭐️⭐️", review: "Loved taking their classes!! ")
//                            reviewCard(reviewRating: "⭐️⭐️⭐️⭐️⭐️", review: "Loved taking their classes!! ")
//                            reviewCard(reviewRating: "⭐️⭐️⭐️⭐️⭐️", review: "Loved taking their classes!! ")
//                        }
//                        .padding([.top,.bottom], 10)
//                        Spacer()
//                    }
//
//                    Spacer()
//                }
//            }
//
//            .padding([.top, .leading, .trailing])
//
//            .background(Color.background)
//
//
//        }
//    }
//}
