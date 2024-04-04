import SwiftUI

struct quickInfoCard: View{
    var tutorAddress: String
    var startTime: String
    var endTime: String
    var tutionFee: Int
    var body: some View{
        VStack{
            //address
            VStack(alignment: .leading){
                Text("Address")
                    .font(AppFont.smallSemiBold)
                HStack{
                    Image("location")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    Text("\(tutorAddress)")
                        .font(AppFont.smallReg)
                    Spacer()
                }
                .offset(y:-5)
            }
            .padding(.bottom, 5)
            
            //timing
            VStack(alignment: .leading){
                Text("Timing")
                    .font(AppFont.smallSemiBold)
//                    .foregroundColor(.gray)
                HStack{
                    Text("\(startTime) - \(endTime)" )
                        .padding(.trailing, 10)
                        .font(AppFont.smallReg)
                    Spacer()
                }
            }
            .padding(.bottom, 5)
            
            //Fee
            VStack(alignment: .leading){
                Text("Fee")
                    .font(AppFont.smallSemiBold)
//                    .foregroundColor(.gray)
                HStack{
                    Text("₹\(tutionFee) /month")
                        .font(AppFont.smallReg)
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 180 )
        .background(.elavated)
        .cornerRadius(10)
        //.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 12)
    }
   
}

#Preview {
    quickInfoCard(tutorAddress: "Fake street name, New York", startTime: "12:00", endTime: "1:00", tutionFee: 2000)
}
