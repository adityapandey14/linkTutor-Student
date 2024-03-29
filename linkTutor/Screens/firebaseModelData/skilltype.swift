//
//  skilltype.swift
//  linkTutor
//
//  Created by Aditya Pandey on 09/03/24.
//




import SwiftUI
import Firebase
import FirebaseFirestore




// Define your data models
struct SkillType: Identifiable, Equatable , Hashable {
    var id: String
    var skillOwnerDetails: [SkillOwnerDetail] = []
    var isAscendingOrder: Bool = true
    
    static func == (lhs: SkillType, rhs: SkillType) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SkillOwnerDetail: Identifiable, Codable , Hashable {
    var id: String
    var academy: String
    var className: String
    var documentUid: String
    var price: Int
    var skillUid: String
    var teacherUid: String
    var week: [String]
    var startTime: Timestamp // Corrected type
    var endTime: Timestamp // Corrected type
    var mode: String
}

// Create a view model to fetch the data
class SkillViewModel: ObservableObject {
    @Published var skillTypes: [SkillType] = []
    private let db = Firestore.firestore()
    
    init() {
        fetchSkillTypes()
    }
    
    func fetchSkillTypes() {
        Task {
            do {
                let querySnapshot = try await db.collection("skillType").getDocuments()
                DispatchQueue.main.async {
                    self.skillTypes = querySnapshot.documents.map { document in
                        SkillType(id: document.documentID)
                    }
                }
            } catch {
                print("Error fetching skill types: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSkillOwnerDetails(for skillType: SkillType) {
        Task {
            do {
                let querySnapshot = try await db.collection("skillType").document(skillType.id).collection("skillOwnerDetails").getDocuments()
                let details = querySnapshot.documents.compactMap { document -> SkillOwnerDetail? in
                    let data = document.data()
                    return SkillOwnerDetail(
                        id: document.documentID,
                        academy: data["academy"] as? String ?? "",
                        className: data["className"] as? String ?? "",
                        documentUid: data["documentUid"] as? String ?? "",
                        price: data["fees"] as? Int ?? 0,
                        skillUid: data["skillUid"] as? String ?? "",
                        teacherUid: data["teacherUid"] as? String ?? "",
                        week: data["week"] as? [String] ?? [],
                        startTime: data["startTime"] as? Timestamp ?? Timestamp(), // Default value if conversion fails
                        endTime: data["endTime"] as? Timestamp ?? Timestamp(), // Default value if conversion fails
                        mode: data["mode"] as? String ?? ""
                    )
                }
                DispatchQueue.main.async {
                    if let index = self.skillTypes.firstIndex(where: { $0.id == skillType.id }) {
                        self.skillTypes[index].skillOwnerDetails = details
                    }
                }
            } catch {
                print("Error fetching skill owner details: \(error.localizedDescription)")
            }
        }
    }
    
    func sortDetailsAscending(for skillType: SkillType) {
        if let index = skillTypes.firstIndex(where: { $0.id == skillType.id }) {
            skillTypes[index].skillOwnerDetails.sort { $0.price < $1.price }
            skillTypes[index].isAscendingOrder = true
        }
    }

    func sortDetailsDescending(for skillType: SkillType) {
        if let index = skillTypes.firstIndex(where: { $0.id == skillType.id }) {
            skillTypes[index].skillOwnerDetails.sort { $0.price > $1.price }
            skillTypes[index].isAscendingOrder = false
        }
    }
}

struct SkillView: View {
    @ObservedObject var viewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.skillTypes) { skillType in
                VStack(alignment: .leading) {
                    Text("Skill Type: \(skillType.id)")
                        .font(.headline)
                        .onTapGesture {
                            selectedSkillType = skillType
                            viewModel.fetchSkillOwnerDetails(for: skillType)
                        }
                        .padding()
                    
                    if selectedSkillType == skillType {
                        HStack {
                            Button("Sort \(skillType.isAscendingOrder ? "Descending" : "Ascending")") {
                                if skillType.isAscendingOrder {
                                    viewModel.sortDetailsDescending(for: skillType)
                                } else {
                                    viewModel.sortDetailsAscending(for: skillType)
                                }
                            }
                            .frame(width: 150, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    }
                    
                    ForEach(skillType.skillOwnerDetails) { detail in
                        VStack(alignment: .leading) {
                            Text("Class Name: \(detail.className)")
                                .padding()
                            Text("Academy: \(detail.academy)")
                                .padding()
                            Text("Price: \(detail.price)")
                                .padding()
                            Text("Week: \(detail.week.joined(separator: ", "))")
                                .padding()
                                .foregroundColor(.red)
                            // Add other fields as needed
                        }
                    }
                }
                .padding()
            }
        }
    }
}



#Preview {
    SkillView()
}






//struct SkillView: View {
//    @ObservedObject var viewModel = SkillViewModel()
//    @State private var selectedSkillType: SkillType?
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                ForEach(viewModel.skillTypes) { skillType in
//                   
//                    VStack(alignment: .leading) {
//                        NavigationLink(destination: SkillDetailsView(skillType: skillType)) {
//                            Text("Skill Type: \(skillType.id)")
//                                .font(.headline)
//                        }
//                        .padding()
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Skill Types")
//        }
//    }
//}

//struct SkillDetailsView: View {
//    let skillType: SkillType
//    @ObservedObject var viewModel = SkillViewModel()
//    @State private var isAscendingOrder = true
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                if let skillTypeIndex = viewModel.skillTypes.firstIndex(where: { $0.id == skillType.id }) {
//                    let skillTypeDetails = viewModel.skillTypes[skillTypeIndex]
//                    
//                    ForEach(skillTypeDetails.skillOwnerDetails) { detail in
//                        VStack(alignment: .leading) {
//                            Text("Class Name: \(detail.className)")
//                                .padding()
//                            Text("Academy: \(detail.academy)")
//                                .padding()
//                            Text("Price: \(detail.price)")
//                                .padding()
//                            // Add other fields as needed
//                        }
//                    }
//                    
//                    HStack {
//                        Button(action: {
//                            if isAscendingOrder {
//                                viewModel.sortDetailsAscending(for: skillType)
//                            } else {
//                                viewModel.sortDetailsDescending(for: skillType)
//                            }
//                            isAscendingOrder.toggle()
//                        }) {
//                            Text("Sort by Price \(isAscendingOrder ? "Descending" : "Ascending")")
//                                .padding()
//                                .foregroundColor(.white)
//                                .background(Color.blue)
//                                .cornerRadius(8)
//                        }
//                    }
//                    .padding()
//                } else {
//                    Text("Loading...")
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Details")
//        .onAppear {
//            viewModel.fetchSkillOwnerDetails(for: skillType)
//        }
//    }
//}











// Create a SwiftUI view to display the fetched data
//struct SkillView: View {
//    @ObservedObject var viewModel = SkillViewModel()
//    @State private var selectedSkillType: SkillType?
//    @State private var showDetailPage = false
//    @State private var selectedDetail: SkillOwnerDetail?
//
//    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                HStack {
//                    Text("Explore skills!")
//                        .font(AppFont.largeBold)
//                    Spacer()
//                }
//            }
//
//            ScrollView {
//                LazyVGrid(columns: columns, spacing: 10) {
//                    ForEach(viewModel.skillTypes) { skillType in
//                        let skillTypeName: String = skillType.id
//                        popularClassCardV(skillId: skillTypeName.prefix(1).capitalized + skillTypeName.dropFirst(), iconName: "book")
//                            .onTapGesture {
//                                selectedSkillType = skillType
//                                viewModel.fetchSkillOwnerDetails(for: skillType)
//                                showDetailPage = true
//                            }
//                            .padding()
//
//                        if selectedSkillType == skillType {
//                            HStack {
//                                Button("Sort \(skillType.isAscendingOrder ? "Descending" : "Ascending")") {
//                                    if skillType.isAscendingOrder {
//                                        viewModel.sortDetailsDescending(for: skillType)
//                                    } else {
//                                        viewModel.sortDetailsAscending(for: skillType)
//                                    }
//                                }
//                                .frame(width: 150, height: 30)
//                                .foregroundColor(.white)
//                                .padding()
//                                .background(Color.blue)
//                                .cornerRadius(8)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $showDetailPage) {
//            if let detail = selectedDetail {
//                classCard(detail: detail)
//            }
//        }
//    }
//}
//
//
//
//// Preview the content
//#Preview {
//    SkillView()
//}
//
//
////struct SkillDetailView: View {
////    let detail: SkillOwnerDetail
////    
////    var body: some View {
////        VStack(alignment: .leading) {
////            Text("Class Name: \(detail.className)")
////                .padding()
////            Text("Academy: \(detail.academy)")
////                .padding()
////            Text("Price: \(detail.price)")
////                .padding()
////            // Add other fields as needed
////        }
////        .navigationBarTitle("Skill Detail", displayMode: .inline)
////    }
////}
//
//
//struct classCard: View{
//    
//    
//
//    let detail: SkillOwnerDetail
//  
//    var body: some View{
//        VStack(alignment: .leading){
//            HStack{
//                //Image(systemName: "person.crop.square")
//                
//                
//                    Image(systemName: "dummyProfilePic")
//                        .resizable()
//                        .clipped()
//                        .frame(width: 85, height: 85)
//                        .cornerRadius(50)
//                        .padding(.trailing, 5)
//                    VStack(alignment: .leading){
//                        Text("\(detail.academy)")
//                            .font(AppFont.mediumSemiBold)
//                        
//                        Text("by \(detail.className)")
//                            .font(AppFont.smallReg)
//                        
//                        //4.5 stars and 40 reviews
//                        HStack{
//                            Text("4.0 ⭐️")
//                                .font(AppFont.smallReg)
//                                .padding([.top, .bottom], 4)
//                                .padding([.leading, .trailing], 8)
//                                .background(.white)
//                                .cornerRadius(50)
//                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 12)
//                            Text("40 reviews")
//                                .font(AppFont.smallReg)
//                                .padding(.leading, 5)
//                                .foregroundColor(.gray)
//                        }
//                        //Spacer()
//                        
//                    }
//                    Spacer()
//                    
//                }
//                
//                //tutor address
//                HStack{
//                    Image("location")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                    Text("Chennai")
//                }
//                
//                HStack{
//                    Image(systemName: "phone.fill")
//                        .font(.system(size: 20))
//                    Text("1234567890")
//                        .font(AppFont.actionButton)
//                }
//                .padding([.top, .bottom], 4)
//                .padding([.leading, .trailing], 12)
//                .background(Color.phoneAccent)
//                .cornerRadius(50)
//                
//                //phone and message option
//                //            HStack{
//                //
//                //                .background(Color.phoneAccent)
//                //
//                //
//                //                HStack{
//                //                    Image(systemName: "message.fill")
//                //                        .font(.system(size: 17))
//                //                    Text("iMessage")
//                //                        .font(AppFont.actionButton)
//                //                }
//                //                .padding([.top, .bottom], 4)
//                //                .padding([.leading, .trailing], 12)
//                //                .overlay(
//                //                    RoundedRectangle(cornerRadius: 20)
//                //                        .stroke(Color.messageAccent, lineWidth: 2)
//                //                )
//                //                .cornerRadius(50)
//                //                .background(Color.messageAccent)
//                //            }
//                
//                
//                
//                //Spacer()
//                
//                
//                
//            }
//            .frame(maxWidth: .infinity, maxHeight: 170)
//            .padding()
//            .foregroundStyle(Color.black)
//            .background(.accent)
//            .cornerRadius(20)
//        }
//    
//}

//#Preview {
//    classCard(detail: SkillOwnerDetail.init(id: "1", academy: "Unknowns", className: "Aditya", documentUid: "1", price: 2000.0 , skillUid: "1", teacherUid: "1"))
//}
















//
//struct SkillView: View {
//    @ObservedObject var viewModel = SkillViewModel()
//    @State private var selectedSkillType: SkillType?
//    
//    var body: some View {
//        ScrollView {
//            ForEach(viewModel.skillTypes) { skillType in
//                VStack(alignment: .leading) {
//                    Text("Skill Type: \(skillType.id)")
//                        .font(.headline)
//                        .onTapGesture {
//                            selectedSkillType = skillType
//                            viewModel.fetchSkillOwnerDetails(for: skillType)
//                        }
//                        .padding()
//                    
//                    if selectedSkillType == skillType {
//                        HStack {
//                            Button("Sort \(skillType.isAscendingOrder ? "Descending" : "Ascending")") {
//                                if skillType.isAscendingOrder {
//                                    viewModel.sortDetailsDescending(for: skillType)
//                                } else {
//                                    viewModel.sortDetailsAscending(for: skillType)
//                                }
//                            }
//                            .frame(width: 150, height: 30)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(8)
//                        }
//                    }
//                    
//                    ForEach(skillType.skillOwnerDetails) { detail in
//                        VStack(alignment: .leading) {
//                            Text("Class Name: \(detail.className)")
//                                .padding()
//                            Text("Academy: \(detail.academy)")
//                                .padding()
//                            Text("Price: \(detail.price)")
//                                .padding()
//                            Text("week: \(detail.week)")
//                                .padding()
//                                .foregroundColor(.red)
//                            // Add other fields as needed
//                        }
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//}


