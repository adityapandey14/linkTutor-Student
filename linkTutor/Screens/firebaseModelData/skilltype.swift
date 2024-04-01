//
//  skilltype.swift
//  linkTutor
//
//  Created by Aditya Pandey on 09/03/24.
//




import SwiftUI
import Firebase
import FirebaseFirestore
import CoreLocation

// Define your data models
struct SkillType: Identifiable, Equatable, Hashable {
    var id: String
    var skillOwnerDetails: [SkillOwnerDetail] = []
    var isAscendingOrder: Bool = true
    
    static func == (lhs: SkillType, rhs: SkillType) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SkillOwnerDetail: Identifiable, Codable, Hashable {
    var id: String
    var academy: String
    var className: String
    var documentUid: String
    var price: Int
    var skillUid: String
    var teacherUid: String
    var week: [String]
    var startTime: Date // Corrected type
    var endTime: Date // Corrected type
    var mode: String
    var location: GeoPoint // assuming GeoPoint is a valid type

    // Include Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Create a view model to fetch the data
class SkillViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var skillTypes: [SkillType] = []
    static let shared = SkillViewModel()
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?

    override init() {
        super.init()
        fetchSkillTypes()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
                        startTime: data["startTime"] as? Date ?? Date(),
                        endTime: data["endTime"] as? Date ?? Date(),
                        mode: data["mode"] as? String ?? "",
                        location: data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0) // Adjust this according to your GeoPoint structure
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

    func sortDetailsByDistance() {
        guard let userLocation = self.userLocation else {
            print("User location is not available.")
            return
        }

        for index in 0..<skillTypes.count {
            skillTypes[index].skillOwnerDetails = skillTypes[index].skillOwnerDetails.filter { detail in
                let location = CLLocation(latitude: detail.location.latitude, longitude: detail.location.longitude)
                let distance = userLocation.distance(from: location) / 1000 // Convert to kilometers

                return distance <= 100
            }

            skillTypes[index].skillOwnerDetails.sort { (detail1, detail2) -> Bool in
                let location1 = CLLocation(latitude: detail1.location.latitude, longitude: detail1.location.longitude)
                let location2 = CLLocation(latitude: detail2.location.latitude, longitude: detail2.location.longitude)

                let distance1 = userLocation.distance(from: location1)
                let distance2 = userLocation.distance(from: location2)

                return distance1 < distance2
            }
        }
    }
    
    func sortDetailsByLocation(for skillType: SkillType) {
        guard let userLocation = self.userLocation else {
            print("User location is not available.")
            return
        }
        
        for index in 0..<skillTypes.count {
            skillTypes[index].skillOwnerDetails.sort { (detail1, detail2) -> Bool in
                let location1 = CLLocation(latitude: detail1.location.latitude, longitude: detail1.location.longitude)
                let location2 = CLLocation(latitude: detail2.location.latitude, longitude: detail2.location.longitude)
                
                let distance1 = userLocation.distance(from: location1)
                let distance2 = userLocation.distance(from: location2)
                
                return distance1 < distance2
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

    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location
            sortDetailsByDistance() // Sort based on user's current location
            manager.stopUpdatingLocation() // Stop updating location to save battery
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

struct SkillView: View {
    @ObservedObject var viewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    @State private var radius: Double = 100 // Default radius of 100 km
    
    var body: some View {
        VStack {
            Slider(value: $radius, in: 0...200, step: 1) {
                Text("Search Radius: \(Int(radius)) km")
            }
            .padding(.horizontal)
            
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
                        
                        HStack {
                            Button("Sort Ascending") {
                                viewModel.sortDetailsAscending(for: skillType)
                            }
                            .frame(width: 150, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)

                            Button("Sort Descending") {
                                viewModel.sortDetailsDescending(for: skillType)
                            }
                            .frame(width: 150, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                        }

                        ForEach(skillType.skillOwnerDetails.filter { detail in
                            // Safely unwrap optional values
                            if let userId = Auth.auth().currentUser?.uid,
                               let userLocation = StudentViewModel.shared.userDetails.first(where: { $0.id == userId })?.location {
                                let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                                let classLocation = CLLocation(latitude: detail.location.latitude, longitude: detail.location.longitude)
                                let distance = calculateDistance(userLocation: location, classLocation: classLocation)
                                return distance <= radius
                            }
                            return false
                        }) { detail in
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
            .onAppear {
                viewModel.sortDetailsByDistance()
            }
        }
    }
    
    // Function to calculate distance between two locations using Haversine formula
     func calculateDistance(userLocation: CLLocation, classLocation: CLLocation) -> Double {
        let earthRadius = 6371.0 // Earth's radius in kilometers
        
        let lat1 = userLocation.coordinate.latitude
        let lon1 = userLocation.coordinate.longitude
        let lat2 = classLocation.coordinate.latitude
        let lon2 = classLocation.coordinate.longitude
        
        let dLat = (lat2 - lat1).degreesToRadians
        let dLon = (lon2 - lon1).degreesToRadians
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1.degreesToRadians) * cos(lat2.degreesToRadians) *
            sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = earthRadius * c // Distance in kilometers
        
        return distance
    }
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
}

// Preview
struct SkillView_Previews: PreviewProvider {
    static var previews: some View {
        SkillView()
    }
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


