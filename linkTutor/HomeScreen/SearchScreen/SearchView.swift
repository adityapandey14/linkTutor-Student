//
//  SearchView.swift
//  linkTutor
//
//  Created by Aditya Pandey on 19/03/24.
//

import SwiftUI

struct SearchView: View {
    @State var searchText = ""
    @ObservedObject var viewModel = SkillViewModel()
    @State private var selectedSkillType: SkillType?
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(5)
                .padding(.leading)
                .background(Color.elavated)
//                .padding(.leading)
                .textFieldStyle(PlainTextFieldStyle())
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
            
            ScrollView{
                VStack {
                    ForEach(viewModel.skillTypes) { skillType in
                        VStack(alignment: .leading) {
                            ForEach(skillType.skillOwnerDetails.filter { self.searchText.isEmpty ? true : $0.className.localizedCaseInsensitiveContains(self.searchText) }, id: \.id) { detail in
                                VStack(alignment: .leading) {
                                    NavigationLink(destination: classLandingPage(teacherUid: detail.teacherUid,
                                                                                 academy: detail.academy,
                                                                                 skillUid: detail.skillUid,
                                                                                 skillOwnerUid: detail.id,
                                                                                 className: detail.className,
                                                                                 startTime: detail.startTime,
                                                                                 endTime: detail.endTime, week: detail.week , mode : detail.mode)) {
                                        VStack{
                                            HStack{
                                                Image(systemName: "magnifyingglass")
                                                    .foregroundStyle(Color.myGray)
                                                Text("\(detail.className) by \(detail.academy)")
                                                    .padding()
                                                Spacer()
                                            }
                                            .foregroundStyle(Color.white).opacity(0.7)
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .onAppear() {
                            viewModel.fetchSkillOwnerDetails(for: skillType)
                        }
                    }
                }
            }
            .onAppear() {
                viewModel.fetchSkillTypes()
            }

        }
        .padding()
        .background(Color.background)
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

