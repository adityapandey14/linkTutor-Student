import SwiftUI

struct listClassesScreen: View{
  
  //  @State private var selectedSortOption: SortOption = .lowToHigh

   
    
    let skillType: SkillType
    @ObservedObject var teacherViewModel = TeacherViewModel.shared
  //  var skillId : SkillType.ID
    @ObservedObject var viewModel = SkillViewModel()
    @State private var isAscendingOrder = true
    @State private var showActionSheet = false

    
    var body: some View {
        NavigationStack {
            VStack{
 
                ScrollView {
                    VStack{

                        VStack(alignment: .leading) {
                            if let skillTypeIndex = viewModel.skillTypes.firstIndex(where: { $0.id == skillType.id }) {
                                let skillTypeDetails = viewModel.skillTypes[skillTypeIndex]
                                
                                ForEach(skillTypeDetails.skillOwnerDetails) { detail in
                                    VStack(alignment: .leading) {
                                        
                                        
                                        
                                        NavigationLink(destination: classLandingPage(teacherUid: detail.teacherUid, academy: detail.academy , skillUid: detail.skillUid , skillOwnerUid: detail.id, className: detail.className, startTime: detail.startTime, endTime: detail.endTime, week: detail.week)) {
                                            
                                            classPreviewCard(academy: detail.academy, className: detail.className, phoneNumber: 1234567890, price: Int(detail.price) , teacherUid : detail.teacherUid)
                                            
                                        }
                                        .padding()
                                    }
                                }
                            } else {
                                Text("Loading...")
                            }
                            
                            
                        }
                        .padding()
                    }
                    .padding()
                } //end of scroll
                .navigationTitle(Text("Details"))
                .navigationBarItems(trailing:
                                Button(action: {
                                    showActionSheet.toggle()
                                }) {
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .font(.system(size: 20))
                                }
                            )
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
                .onAppear {
                    viewModel.fetchSkillOwnerDetails(for: skillType)
                }
                    
                
            }
            .background(Color.background)
          
            
        }
        
    }
    
}


#Preview {
    listClassesScreen(skillType: SkillType(id: "1"))
}




