import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct homeScreen: View{
    @StateObject var viewModel = listClassesScreenModel()
    @EnvironmentObject var dataModel : AuthViewModel
    @ObservedObject var studentViewModel = StudentViewModel.shared
    
    @ObservedObject var skillViewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    
    @StateObject var viewModel1 = RequestListViewModel()
    @State private var selectedDate: Date = Date()
    let userId = Auth.auth().currentUser?.uid
   
    
    var body: some View{
       
        NavigationStack{
            VStack{
                VStack{
                    if let fullName = studentViewModel.userDetails.first?.fullName {
                        let nameComponents = fullName.components(separatedBy: " ")
                        let firstName = nameComponents.first ?? ""
                        header(yourName: firstName)
                            .padding(.bottom)
                    
                    }
                    else {
                        header(yourName: "there")
                            .padding(.bottom)
                    }
                       
                    NavigationLink(destination: SearchView()){
                        HStack{
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.myGray)
                            Text("Skills, tutors, centers...")
                            
                            Spacer()
                        }
                        .foregroundStyle(Color.gray).opacity(0.7)
                        .padding(3)
                        .padding(.leading, 10)
                        .frame(width: 370, height: 35)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                       
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 15)
                .onAppear {
                  
                    Task {
                        let userId = Auth.auth().currentUser?.uid
                        await studentViewModel.fetchStudentDetailsByID(studentID: userId ?? "")
                    }
                }
                
                ScrollView(.vertical, showsIndicators: false){
                    VStack{
                        //Enrolled classes section
                        SectionHeader(sectionName: "Todays Classes", fileLocation: enrolledSubjectList())
                            .onTapGesture {
                                viewModel.enrolledClassFramework = enrolledClassVList(classdata: enrolledClassMockData.sampleClassData)
                            }
                            .padding(.horizontal)
                        
                        //enrolled classes cards
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                if let classesForSelectedDate = classesForSelectedDate(), !classesForSelectedDate.isEmpty {
                                    ForEach(classesForSelectedDate.filter { $0.studentUid == userId && $0.requestAccepted == 1 }, id: \.id) { enrolledClass in
                                        calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                                    }
                                    
                                } else {
                                    Text("No classes found")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                        }
                        .padding(.leading)
                        
                        
                        //Explore skills section
                        SectionHeader(sectionName: "Explore Skills!", fileLocation: allPopularCard())
                            .padding(.horizontal)
                        
                        //explore classes cards
                        allPopularCardHomePage()
                        
                        Spacer().frame(height: 130)
                        
                        HStack{
                            Spacer()
                            Text("Here's to unlocking your full potential!")
                                .font(AppFont.actionButton)
                                .foregroundStyle(Color.gray)
                            Spacer()
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
                    .edgesIgnoringSafeArea(.bottom)
            }//v end
            .background(Color.background)
            .environment(\.colorScheme, .light)
        }
//        .padding()
        .background(Color.background)
        .onAppear {
            viewModel1.fetchEnrolledStudents()
        }
    }
    func formattedWeekday(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    func classesForSelectedDate() -> [EnrolledStudent]? {
         return viewModel1.enrolledStudents.filter { enrolledClass in
             enrolledClass.week.contains(formattedWeekday(for: Date()))
         }
     }
    
    
}
    


#Preview {
    homeScreen()
}


