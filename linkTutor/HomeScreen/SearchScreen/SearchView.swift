//
//  SearchView.swift
//  linkTutor
//
//  Created by Aditya Pandey on 19/03/24.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @ObservedObject var viewModel = SkillViewModel()
    @ObservedObject var teacherViewModel = TeacherViewModel.shared
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(5)
                .padding(.leading)
                .background(Color.elavated)
                .textFieldStyle(PlainTextFieldStyle())
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
            
            ScrollView {
                ForEach(viewModel.skillTypes) { skillType in
                    VStack(alignment: .leading) {
                        ForEach(skillType.skillOwnerDetails.filter { searchText.isEmpty || $0.className.localizedCaseInsensitiveContains(searchText) }, id: \.id) { detail in
                            if let teacherDetail = teacherViewModel.teacherDetails.first(where: { $0.id == detail.teacherUid }) {
                                NavigationLink(destination: classLandingPage(teacherUid: detail.teacherUid,
                                                                                 academy: detail.academy,
                                                                                 skillUid: detail.skillUid,
                                                                                 skillOwnerUid: detail.id,
                                                                                 className: detail.className,
                                                                                 startTime: detail.startTime,
                                                                                 endTime: detail.endTime,
                                                                                 week: detail.week,
                                                                                 mode: detail.mode ,
                                                                             teacherDetail: teacherDetail,
                                                                             price : detail.price)) {
                                    VStack {
                                        HStack {
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
                    .onAppear {
                        viewModel.fetchSkillOwnerDetails(for: skillType)
                    }
                }
            }
            .onAppear {
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

