import SwiftUI
import CoreLocation
import FirebaseAuth

struct listClassesScreen: View {
    let skillType: SkillType
    @ObservedObject var viewModel = SkillViewModel()
    @State private var isAscendingOrder = true
    @State private var showActionSheet = false
    @ObservedObject var teacherViewModel = TeacherViewModel.shared
    @State private var sortByLocation = false
    @State private var radius: Double = 100 // Initial radius for filtering classes

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack{
                            Spacer()
                            Button(action: {
                                showActionSheet.toggle()
                            }) {
                                HStack{
                                    Text("Filter")
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .font(.system(size: 20))
                                }
                            }
                            .font(.body) // Changed to .body font
                            .frame(minWidth: 90, minHeight: 30)
                            .foregroundColor(.accentColor) // Changed to .accentColor
                            .background(.ultraThinMaterial) // Changed to .secondary color
                            .cornerRadius(8)
                            .actionSheet(isPresented: $showActionSheet) {
                                ActionSheet(
                                    title: Text("Filter Options"),
                                    buttons: [
                                        .default(Text("Low to High Price")) {
                                            if isAscendingOrder {
                                                viewModel.sortDetailsAscending(for: skillType)
                                            }
                                            isAscendingOrder.toggle()
                                        },
                                        .default(Text("High to Low Price")) {
                                            if !isAscendingOrder {
                                                viewModel.sortDetailsDescending(for: skillType)
                                            }
                                            isAscendingOrder.toggle()
                                        },
                                        .default(Text("Sort by Location")) {
                                            sortByLocation.toggle()
                                            if sortByLocation {
                                                // No need to sort initially, it will be sorted based on radius
                                                viewModel.sortDetailsByDistance() // Initial sorting
                                            }
                                        },
                                        .cancel(Text("Cancel")), // Specifying Cancel button text
                                    ]
                                )
                            }
                            
                            if sortByLocation {
                                Slider(value: $radius, in: 0...200, step: 1) {
                                    Text("Search Radius: \(Int(radius)) km")
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        if let skillTypeIndex = viewModel.skillTypes.firstIndex(where: { $0.id == skillType.id }) {
                            let skillTypeDetails = viewModel.skillTypes[skillTypeIndex]
                            ForEach(skillTypeDetails.skillOwnerDetails.filter { detail in
                                // Filter based on selected radius
                                if let userId = Auth.auth().currentUser?.uid,
                                   sortByLocation,
                                   let userLocation = StudentViewModel.shared.userDetails.first(where: { $0.id == userId })?.location {
                                    let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                                    let classLocation = CLLocation(latitude: detail.location.latitude, longitude: detail.location.longitude)
                                    let distance = SkillView().calculateDistance(userLocation: location, classLocation: classLocation)
                                    return distance <= radius
                                }
                                return true
                            }) { detail in
                                if let teacherDetailIndex = teacherViewModel.teacherDetails.firstIndex(where: { $0.id == detail.teacherUid }) {
                                    let teacherDetail = teacherViewModel.teacherDetails[teacherDetailIndex]
                                    NavigationLink(destination: classLandingPage(
                                        teacherUid: detail.teacherUid,
                                        academy: detail.academy ,
                                        skillUid: detail.skillUid , 
                                        skillOwnerUid: detail.id,
                                        className: detail.className,
                                        startTime: detail.startTime,
                                        endTime: detail.endTime,
                                        week: detail.week ,
                                        mode : detail.mode ,
                                        teacherDetail : teacherDetail ,
                                        price : detail.price ,
                                        skillOnwerDetailsUid: detail.id)) {
                                            
                                        classPreviewCard(academy: detail.academy, 
                                                         className: detail.className,
                                                         skillOnwerDetailsUid: detail.id ,
                                                         price: Int(detail.price),
                                                         teacherUid: detail.teacherUid,
                                                         teacherDetail: teacherDetail)
                                    }
                                }
                            }
                        } else {
                            Text("Loading...")
                        }
                    }
                    .padding()
                    .background(Color.background)
                }
                .onAppear {
                    viewModel.fetchSkillOwnerDetails(for: skillType)
                    Task {
                        await teacherViewModel.fetchTeacherDetails()
                    }
                }
            }
//            .background(Color.background) // Changed to systemBackground color
        } //nav end
        .navigationBarTitle("\(skillType.id)".capitalized, displayMode: .inline)
    }
}

//Preview
struct listClassesScreen_Previews: PreviewProvider {
    static var previews: some View {
        listClassesScreen(skillType: SkillType(id: "1"))
    }
}
