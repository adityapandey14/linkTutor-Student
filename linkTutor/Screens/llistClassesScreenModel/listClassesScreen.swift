import SwiftUI

struct listClassesScreen: View {
    let skillType: SkillType
    @ObservedObject var viewModel = SkillViewModel()
    @State private var isAscendingOrder = true
    @State private var showActionSheet = false
    @ObservedObject var teacherViewModel = TeacherViewModel.shared // Added teacherViewModel

    var body: some View {
        NavigationStack {
            ZStack {
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
                            .font(.headline)
                            .frame(minWidth: 90, minHeight: 30)
                            .foregroundColor(.accentColor)
                            .background(Color.gray.opacity(0.2))
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
                                            if isAscendingOrder == false {
                                                viewModel.sortDetailsDescending(for: skillType)
                                            }
                                                isAscendingOrder.toggle()
                                        },
                                        .cancel(),
                                    ]
                                )
                            }
                        }
                        if let skillTypeIndex = viewModel.skillTypes.firstIndex(where: { $0.id == skillType.id }) {
                            let skillTypeDetails = viewModel.skillTypes[skillTypeIndex]
                            ForEach(skillTypeDetails.skillOwnerDetails) { detail in
                                if let teacherDetailIndex = teacherViewModel.teacherDetails.firstIndex(where: { $0.id == detail.teacherUid }) {
                                    let teacherDetail = teacherViewModel.teacherDetails[teacherDetailIndex]
                                    NavigationLink(destination: classLandingPage(teacherUid: detail.teacherUid, academy: detail.academy , skillUid: detail.skillUid , skillOwnerUid: detail.id, className: detail.className, startTime: detail.startTime, endTime: detail.endTime, week: detail.week ,  mode : detail.mode)) {
                                        
                                        classPreviewCard(academy: detail.academy, className: detail.className, phoneNumber: 123456789 ,  price: Int(detail.price), teacherUid: detail.teacherUid, teacherDetail: teacherDetail)
                                    }
                                    
                                }
                            }
                        } else {
                            Text("Loading...")
                        }
                    }
                    .padding()
                }
                .navigationTitle("Details")
                .onAppear {
                    viewModel.fetchSkillOwnerDetails(for: skillType)
                    Task {
                        await teacherViewModel.fetchTeacherDetails() // Fetch teacher details
                    }
                }
            }
            .background(Color.background)
        }
    }
}


#Preview {
    listClassesScreen(skillType: SkillType(id: "1"))
}
