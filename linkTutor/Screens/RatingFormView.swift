//
//  RatingFormView.swift
//  linkTutor
//
//  Created by Aditya Pandey on 13/03/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RatingFormView: View {
    @State private var rating: Int = 0
    @State private var feedback: String = ""
    var className: String
    var skillOwnerDetailsUId: String
    var teacherUid: String
    var skillUid: String
    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var reviewViewModel = ReviewViewModel()
    @State private var showSubmitAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
            VStack(alignment: .center) {
                HStack{
                    Spacer()
                    Text("Rate Your Experience")
                        .font(AppFont.mediumSemiBold)
                        .foregroundStyle(Color.black)
                    Spacer()
                }
                .padding(.bottom, 40)
                
                // Star Rating
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= self.rating ? "star.fill" : "star.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.yellow)
                            .opacity(index <= self.rating ? 1.0 : 0.3)
                            .onTapGesture {
                                self.rating = index
                            }
                        
                    }
                }
                .padding(.bottom, 20)
                
                // Feedback TextField
                TextField("Enter your feedback", text: $feedback, axis: .vertical)
                    .lineLimit(5...10)
                    .padding()
                    .background(Color.elavated)
                    .foregroundStyle(Color.white)
                    .cornerRadius(8)

                Spacer()
                
                // Submit Button
                Button(action: {
                    showSubmitAlert.toggle()
                    presentationMode.wrappedValue.dismiss()
                    Task {
                        let userId = Auth.auth().currentUser?.uid
                        
                        try await viewModel.addReview(comment: feedback,
                                                      ratingStar: rating,
                                                      skillOwnerDetailsUid: skillOwnerDetailsUId,
                                                      skillUid: skillUid,
                                                      teacherUid: teacherUid,
                                                      className: className)
                    }
                }) {
                    Text("Submit")
                        .font(AppFont.mediumSemiBold)
                        .foregroundColor(.white)
                }
                .frame(width:250, height: 35)
                .padding()
                .background(Color.accent)
                .cornerRadius(50)
                .alert(isPresented: $showSubmitAlert) {
                    Alert(
                        title: Text("Thank you for your feedback!"),
                        message: Text("Your review has been posted"),
                        dismissButton: .default(Text("Okay"))
                    )
                }
            }
            .padding()
            .background(Color.background)
    }
}

struct RatingFormView_Previews: PreviewProvider {
    static var previews: some View {
        RatingFormView(className: "className", skillOwnerDetailsUId: "skillOwnerDetailsUId", teacherUid: "teacherUid", skillUid: "skillUid")
    }
}





