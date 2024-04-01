//
//  homepageComplete.swift
//  linkTutor
//
//  Created by user2 on 03/03/24.
//

import SwiftUI


struct homepageComplete: View {
    var body: some View {
        NavigationStack {
            TabView {
                homeScreen()
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .padding(.top)
                    }

                CalendarView()
                    .tabItem {
                        Label("Timetable" , systemImage: "calendar")
                    }
                
                RequestSent()
                    .tabItem {
                        Label("Requests" , systemImage: "shared.with.you")
                    }
                
                enrolledSubjectList()
                    .tabItem {
                        Label("Enrolled" , systemImage: "person.3.sequence")
                    }
                
                SkillView()
                    .tabItem {
                        Label("skillView" , systemImage: "person.3.sequence")
                    }
                
            }
            .accentColor(Color.accent)
        }
        .tint(Color.accent)
        .accentColor(Color.accent)
        //.navigationBarHidden(false)
//        .preferredColorScheme(.dark)
    }
}

#Preview {
    homepageComplete()
}
