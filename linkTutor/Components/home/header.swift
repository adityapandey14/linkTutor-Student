import SwiftUI

struct header: View{
    @ObservedObject var studentViewModel = StudentViewModel.shared
    
    var yourName: String
    var body: some View{
        HStack(alignment: .top){
            VStack(alignment: .leading){
                HStack{
                    Text("Hi")
                        .font(AppFont.largeBold)
                    Text(yourName)
                        .font(AppFont.largeBold)
                    Spacer()
                }
//                Text("what are you looking for today?")
                Text("Explore new skills!")
                    .font(AppFont.mediumReg)
            }
            Spacer()
            VStack{
                //myProfileView
                NavigationLink(destination: myProfileView()){
                    if let imageUrl = studentViewModel.userDetails.first?.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .clipped()
                                .frame(width: 50, height: 50)
                                .cornerRadius(50)
                                .padding(.trailing, 5)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .clipped()
                                .frame(width: 50, height: 50)
                                .cornerRadius(50)
                                .padding(.trailing, 5)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .clipped()
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                            .padding(.trailing, 5)
                            .foregroundColor(.gray)
                    }
                }
//                Spacer()
            }
        }
    }
}
#Preview {
        header(yourName: "Emma")
}

struct header2: View{
    @ObservedObject var studentViewModel = StudentViewModel.shared
    
    var yourName: String
    var body: some View{
        VStack(alignment: .trailing){
            HStack{
                NavigationLink(destination: myProfileView()){
                    if let imageUrl = studentViewModel.userDetails.first?.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .clipped()
                                .frame(width: 50, height: 50)
                                .cornerRadius(50)
                            //                                .padding(.trailing, 5)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .clipped()
                                .frame(width: 50, height: 50)
                                .cornerRadius(50)
                            //                                .padding(.trailing, 5)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 90, height: 90)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .clipped()
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                        //                            .padding(.trailing, 5)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                HStack{
                    Text("Hi")
                        .font(AppFont.largeBold)
                    Text(yourName)
                        .font(AppFont.largeBold)
                    Spacer()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            HStack{
                Spacer()
                Text("what are you looking for today?")
                    .font(AppFont.mediumReg)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
//        .fixedSize()
    }
}

#Preview {
    header2(yourName: "Emma")
}
