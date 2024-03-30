//
//  allPopularCard.swift
//  linkTutor
//
//  Created by user2 on 11/02/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct allPopularCard: View {
    @ObservedObject var skillViewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    
    
    let columns : [GridItem] = [GridItem(.flexible()) ,GridItem(.flexible())]
    
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Text("Explore Skills!")
                        .font(AppFont.largeBold)
                    Spacer()
                }
                ScrollView{
                    VStack(alignment: .center, spacing: 15){
                        ForEach(skillViewModel.skillTypes) { skillType in
                            let skillTypeName : String = skillType.id
                            NavigationLink(destination: listClassesScreen(skillType: skillType)){
                                popularClassCardV(skillId: skillTypeName.prefix(1).capitalized + skillTypeName.dropFirst(), iconName: "art")
                                
                            }
                            
                            
                        }
                        
                    }//cards end
                }
                Spacer()
            }
            .padding(.horizontal)
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.background)
//            .environment(\.colorScheme, .dark)
        }
    }
}

#Preview {
    allPopularCard()
}

struct popularClassCardV: View{
    @ObservedObject var viewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    var skillId : String
    var iconName: String
    var body: some View{
        HStack {
            //icon
            VStack{
                Spacer()
                HStack{
                    Image("\(skillId)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                    Spacer()
                }
                Spacer()
            }
            
            //class
            VStack{
                Spacer().frame(height: 10)
                HStack{
                    Text("\(skillId)")
                        .font(.system(size: 27, weight: .semibold, design: .rounded))
                        .scaledToFit()
                    //.minimumScaleFactor(0.6)
                    Spacer()
                }
                Spacer()
            }
//            //tutor
//            Text("by \(classData.studentsData.diffClassType.tutorName)")
//                .font(AppFont.smallReg)
//                .scaledToFit()
//                //.minimumScaleFactor(0.6)
                
            
        }
        .frame(maxWidth: .infinity, maxHeight: 90)
        .padding(10)
        .foregroundColor(.black)
        .background(Color.elavated)
        .cornerRadius(20)
    }
}

#Preview {
    popularClassCardV(skillId: "Dance", iconName: "art")
}

struct popularClassCardH: View{
    @ObservedObject var viewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    var skillId : String
    var iconName: String
    var body: some View{
        VStack{
            Spacer()
            Image("\(skillId)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            Text("\(skillId)")
                .font(.system(size: 27, weight: .semibold, design: .rounded))
                .scaledToFit()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
        .foregroundColor(.elavated)
        .background(Color.accent)
        .cornerRadius(20)
    }
}

#Preview {
    popularClassCardH(skillId: "Dance", iconName: "art")
}

struct allPopularCardHomePage: View {
    @ObservedObject var skillViewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    
    
    let columns : [GridItem] = [GridItem(.flexible()) ,GridItem(.flexible())]
    let rows: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center, spacing: 15){
                        ForEach(skillViewModel.skillTypes) { skillType in
                            let skillTypeName : String = skillType.id
                            NavigationLink(destination: listClassesScreen(skillType: skillType)){
                            popularClassCardV(skillId: skillTypeName.prefix(1).capitalized + skillTypeName.dropFirst(), iconName: "art")
                                
                            }
                        }
                    }
//            ScrollView(.horizontal) {
//                LazyHGrid(rows: rows, spacing: 10) {
//                    ForEach(skillViewModel.skillTypes.prefix(5), id: \.id) { skillType in
//                        NavigationLink(destination: listClassesScreen(skillType: skillType)) {
//                            popularClassCardH(skillId: skillType.id.prefix(1).capitalized + skillType.id.dropFirst(), iconName: "art")
//                        }
//                    }
//                    
//                    ForEach(skillViewModel.skillTypes.suffix(5), id: \.id) { skillType in
//                        NavigationLink(destination: listClassesScreen(skillType: skillType)) {
//                            popularClassCardH(skillId: skillType.id.prefix(1).capitalized + skillType.id.dropFirst(), iconName: "art")
//                        }
//                    }
//                }
//            }
            .padding(.horizontal)
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.background)
//            .environment(\.colorScheme, .dark)
     
            }
        }
}

#Preview{
    allPopularCardHomePage()
}
