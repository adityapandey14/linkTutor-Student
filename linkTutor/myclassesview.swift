//
//  myClassesView.swift
//  linkTutor
//
//  Created by admin on 04/04/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct myClassesView: View {
    @StateObject var viewModel = RequestListViewModel()
    @State private var selectedDate: Date = Date()
    let userId = Auth.auth().currentUser?.uid

    
    let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading){
            Text("My Timetable")
                .font(AppFont.largeBold)
                .padding()
            
            
            //the timetables
            
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading){
                    Text(dateDescription(for: selectedDate))
                        .font(.headline)
                        .padding()
                    
                    VStack(spacing: 10){
                        
                        
                        if let classesForSelectedDate = classesForSelectedDate(), !classesForSelectedDate.isEmpty {
                            ForEach(classesForSelectedDate.filter { $0.studentUid == userId && $0.requestAccepted == 1 }, id: \.id) { enrolledClass in
                                calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                            }
                            
                        } else {
                            Text("No classes found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    
                    Text(dateDescription(for: selectedDate.addingTimeInterval(24 * 60 * 60)))
                        .font(.headline)
                        .padding()
                        
                    VStack(spacing: 10) {
                        
                        if let classesForSelectedDate = classesForNextToSelectedDate(), !classesForSelectedDate.isEmpty {
                            if let userId = Auth.auth().currentUser?.uid {
                                ForEach(classesForSelectedDate, id: \.id) { enrolledClass in
                                    if enrolledClass.studentUid == userId {
                                        calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                                    }
                                }
                            }
                        } else {
                            Text("No classes found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Text(dateDescription(for: selectedDate.addingTimeInterval(2 * 24 * 60 * 60)))
                        .font(.headline)
                        .padding()
                    
                    VStack(spacing: 10) {
                        if let classesForThirdToSelectedDate = classesForThirdToSelectedDate(), !classesForThirdToSelectedDate.isEmpty {
                            ForEach(classesForThirdToSelectedDate, id: \.id) { enrolledClass in
                                    if enrolledClass.teacherUid == userId && enrolledClass.requestAccepted == 1 {
                                    calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                                    }
                                }
                        } else {
                            Text("No classes found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Text(dateDescription(for: selectedDate.addingTimeInterval(3 * 24 * 60 * 60)))
                        .font(.headline)
                        .padding()
                    
                    VStack(spacing: 10) {
                        if let classesForFourthToSelectedDate = classesForFourthToSelectedDate(), !classesForFourthToSelectedDate.isEmpty {
                            ForEach(classesForFourthToSelectedDate, id: \.id) { enrolledClass in
                                    if enrolledClass.teacherUid == userId && enrolledClass.requestAccepted == 1 {
                                    calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                                    }
                                }
                        } else {
                            Text("No classes found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Text(dateDescription(for: selectedDate.addingTimeInterval(4 * 24 * 60 * 60)))
                        .font(.headline)
                        .padding()
                    
                    VStack(spacing: 10) {
                        if let classesForFifthToSelectedDate = classesForFifthToSelectedDate(), !classesForFifthToSelectedDate.isEmpty {
                            ForEach(classesForFifthToSelectedDate, id: \.id) { enrolledClass in
                                    if enrolledClass.teacherUid == userId && enrolledClass.requestAccepted == 1 {
                                    calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                                    }
                                }
                        } else {
                            Text("No classes found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Text(dateDescription(for: selectedDate.addingTimeInterval(5 * 24 * 60 * 60)))
                        .font(.headline)
                        .padding()
                    
                    VStack(spacing: 10) {
                        if let classesForSixthToSelectedDate = classesForSixthToSelectedDate(), !classesForSixthToSelectedDate.isEmpty {
                            ForEach(classesForSixthToSelectedDate, id: \.id) { enrolledClass in
                                    if enrolledClass.teacherUid == userId && enrolledClass.requestAccepted == 1 {
                                    calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                                    }
                                }
                        } else {
                            Text("No classes found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Text(dateDescription(for: selectedDate.addingTimeInterval(6 * 24 * 60 * 60)))
                        .font(.headline)
                        .padding()
                    
                    VStack(spacing: 10) {
                        if let classesForSeventhToSelectedDate = classesForSeventhToSelectedDate(), !classesForSeventhToSelectedDate.isEmpty {
                            ForEach(classesForSeventhToSelectedDate, id: \.id) { enrolledClass in
                                    if enrolledClass.teacherUid == userId && enrolledClass.requestAccepted == 1 {
                                    calenderPage(className: enrolledClass.className, tutorName: enrolledClass.teacherName, startTime: enrolledClass.startTime.dateValue())
                                    }
                                }
                        } else {
                            Text("No classes found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    
                }
            } //scrollview end
            Spacer()
        }
        .padding()
        .background(Color.background)
        .onAppear {
            viewModel.fetchEnrolledStudents()
        }
    }
    
    func formattedWeekday(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    func dateDescription(for date: Date) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let selectedDay = Calendar.current.startOfDay(for: date)
        
        if selectedDay == today {
            return "Today, \(formattedWeekday(for: date))"
        } else if selectedDay == tomorrow {
            return "Tomorrow, \(formattedWeekday(for: date))"
        } else {
            return "Selected \(formattedWeekday(for: date))"
        }
        
    }
    
    func classesForSelectedDate() -> [EnrolledStudent]? {
         return viewModel.enrolledStudents.filter { enrolledClass in
             enrolledClass.week.contains(formattedWeekday(for: selectedDate))
         }
     }
    
    func classesForNextToSelectedDate() -> [EnrolledStudent]? {
         return viewModel.enrolledStudents.filter { enrolledClass in
             enrolledClass.week.contains(formattedWeekday(for: selectedDate.addingTimeInterval(24 * 60 * 60)))
         }
     }
    
    func classesForThirdToSelectedDate() -> [EnrolledStudent]? {
        return viewModel.enrolledStudents.filter { enrolledClass in
            enrolledClass.week.contains(formattedWeekday(for: selectedDate.addingTimeInterval(2 * 24 * 60 * 60)))
        }
    }
    
    func classesForFourthToSelectedDate() -> [EnrolledStudent]? {
        return viewModel.enrolledStudents.filter { enrolledClass in
            enrolledClass.week.contains(formattedWeekday(for: selectedDate.addingTimeInterval(3 * 24 * 60 * 60)))
        }
    }
    
    func classesForFifthToSelectedDate() -> [EnrolledStudent]? {
        return viewModel.enrolledStudents.filter { enrolledClass in
            enrolledClass.week.contains(formattedWeekday(for: selectedDate.addingTimeInterval(4 * 24 * 60 * 60)))
        }
    }
    
    func classesForSixthToSelectedDate() -> [EnrolledStudent]? {
        return viewModel.enrolledStudents.filter { enrolledClass in
            enrolledClass.week.contains(formattedWeekday(for: selectedDate.addingTimeInterval(5 * 24 * 60 * 60)))
        }
    }
    
    func classesForSeventhToSelectedDate() -> [EnrolledStudent]? {
        return viewModel.enrolledStudents.filter { enrolledClass in
            enrolledClass.week.contains(formattedWeekday(for: selectedDate.addingTimeInterval(6 * 24 * 60 * 60)))
        }
    }
    
}

struct myClassesView_Previews: PreviewProvider {
    static var previews: some View {
        myClassesView()
    }
}
