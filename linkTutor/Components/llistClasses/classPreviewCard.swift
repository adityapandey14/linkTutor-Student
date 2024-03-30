import SwiftUI
import Firebase

struct classPreviewCard: View {
    var academy: String
    var className: String
    var skillOnwerDetailsUid : String
    var price: Int
    var teacherUid: String
    var teacherDetail: TeacherDetails // New parameter
    @ObservedObject var reviewViewModel = ReviewViewModel()
    
    @State private var isCopied = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack {
                    if let imageUrl = URL(string: teacherDetail.imageUrl) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .clipped()
                                .frame(width: 85, height: 85)
                                .cornerRadius(50)
                                .padding(.trailing, 5)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .clipped()
                                .frame(width: 85, height: 85)
                                .cornerRadius(50)
                                .padding(.trailing, 5)
                        }
                        .frame(width: 90, height: 90)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .clipped()
                            .frame(width: 85, height: 85)
                            .cornerRadius(50)
                            .padding(.trailing, 5)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("\(className)")
                        .font(AppFont.mediumSemiBold)
                    Text("by \(teacherDetail.fullName)")
                        .font(AppFont.smallReg)
                    
                    //reviews
                    HStack {
                        let reviewsForSkillOwner = reviewViewModel.reviewDetails.filter { $0.teacherUid == teacherUid && $0.skillOwnerDetailsUid == skillOnwerDetailsUid }
                                                              
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
                    


                       

                    }
                    .font(AppFont.smallReg)
                    .onAppear() {
                            ReviewDetails().fetchReviewDetails()
                        }
                    
                 
                    HStack{

                        Text("\(teacherDetail.city)")
                            .font(AppFont.smallReg)
                    }
                    .foregroundColor(.black).opacity(0.6)
            
                    Text("Rs. \(price) /month")
                        .font(.headline)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding()
        .foregroundColor(Color.black)
        .background(Color.elavated)
        .cornerRadius(20)
    }
}

struct classPreviewCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTeacherDetail = TeacherDetails(id: "1", aboutParagraph: "Sample about paragraph", city: "Sample City", email: "sample@email.com", documentUid: "sampleDocUid", fullName: "John Doe", location: GeoPoint(latitude: 0, longitude: 0), occupation: "Sample Occupation", phoneNumber: 123456789, imageUrl: "https://example.com/image.jpg")
        classPreviewCard(academy: "Viki's Academy", className: "Unknown", skillOnwerDetailsUid: "skillOwnerDetailsUid",  price: 2000, teacherUid: "1", teacherDetail: sampleTeacherDetail)
    }
}



//phone
//                    HStack {
//                        HStack {
//                            Image(systemName: "phone.fill")
//                                .font(.system(size: 20))
//
//                            Text(String("\(teacherDetail.phoneNumber)"))
//                                .font(.headline)
//                        }
//                        .foregroundColor(.black)
//                        .padding([.top, .bottom], 4)
//                        .padding([.leading, .trailing], 12)
//                        .background(Color.phoneAccent)
//                        .cornerRadius(50)
//                        .onTapGesture {
//                            let phoneNumberString = "\(phoneNumber)"
//                            UIPasteboard.general.string = phoneNumberString
//
//                            isCopied = true
//                        }
//                        .alert(isPresented: $isCopied) {
//                            Alert(title: Text("Copied!"), message: Text("Phone number copied to clipboard."), dismissButton: .default(Text("OK")))
//                        }
//
//                        Spacer()
//                    }
