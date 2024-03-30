import SwiftUI

struct quickInfoCard: View{
    var tutorAddress: String
    var startTime: Date
    var endTime: Date
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
                    Text(formattedTime(startTime)!)
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
    
     func formattedTime(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // Date format: dayOfMonth month year hour:minute AM/PM
        return dateFormatter.string(from: date)
    }
}

#Preview {
    quickInfoCard(tutorAddress: "Fake street name, New York", startTime: Date(), endTime: Date(), tutionFee: 2000)
}
