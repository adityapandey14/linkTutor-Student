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
                                .foregroundColor(.gray)
                        }
                        .frame(width: 90, height: 90)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .clipped()
                            .frame(width: 85, height: 85)
                            .cornerRadius(50)
                            .padding(.trailing, 5)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("\(className)")
                        .font(AppFont.mediumSemiBold)
                    Text("by \(teacherDetail.fullName)")
                        .font(AppFont.smallReg)
                        .foregroundStyle(Color.black).opacity(0.6)
                        .padding(.bottom, 0.5)
                    
                    //reviews
                    HStack{
                        let reviewsForSkillOwner = reviewViewModel.reviewDetails.filter { $0.teacherUid == teacherUid && $0.skillOwnerDetailsUid == skillOnwerDetailsUid }
                                                              
                        if !reviewsForSkillOwner.isEmpty {
                            let averageRating = reviewsForSkillOwner.reduce(0.0) { $0 + Double($1.ratingStar) } / Double(reviewsForSkillOwner.count)
                            
                            Text("\(averageRating, specifier: "%.1f") ⭐️")
//                                .padding([.top, .bottom], 3)
//                                .padding([.leading, .trailing], 9)
//                                .background(Color.background)
//                                .cornerRadius(50)
                                .font(AppFont.smallReg)
                            
                            Text("\(reviewsForSkillOwner.count) Review\(reviewsForSkillOwner.count == 1 ? "" : "s")")
                                .font(AppFont.smallReg)
                        } else {
                            Text("no reviews")
                                .font(AppFont.smallReg)
                                .foregroundColor(.black).opacity(0.3)
//                                .padding(.bottom)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 4)
//                    .padding(.top, 1)
                    .font(AppFont.smallReg)
                    .onAppear() {
                            ReviewDetails().fetchReviewDetails()
                        }
                    
                    if !(teacherDetail.city).isEmpty{
                        Text("\(teacherDetail.city)".capitalized)
                            .font(AppFont.smallReg)
                            .padding(.bottom, 1)
                            .foregroundColor(.black).opacity(0.6)
                    }
                    
                    HStack{
                        Text("Rs. \(price) ")
                            .foregroundStyle(Color.accent)
                            .font(AppFont.smallSemiBold)
                        Text("/month")
                            .foregroundStyle(Color.black).opacity(0.3)
                            .font(AppFont.smallReg)
                    }
                    
                    
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
        let sampleTeacherDetail = TeacherDetails(id: "1", aboutParagraph: "Sample about paragraph", city: "sample City", email: "sample@email.com", documentUid: "sampleDocUid", fullName: "John Doe", location: GeoPoint(latitude: 0, longitude: 0), occupation: "Sample Occupation", phoneNumber: 123456789, imageUrl: "https://example.com/image.jpg")
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
