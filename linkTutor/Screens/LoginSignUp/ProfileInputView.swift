import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

struct CustomSectionHeader: View {
    var title: String

    var body: some View {
        HStack{
            Text(title)
                .font(AppFont.mediumSemiBold)
                .textCase(.none)// Customize background color as needed
            Spacer()
        }
    }
}

struct ProfileInputView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
  
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var city: String = ""
    @State private var phoneNumber: Int = 91
    @State private var about: String = ""
    @State private var occupation : String = ""
    @State private var age : String = ""

  
    @State private var location: GeoPoint = GeoPoint(latitude: 12.8096, longitude: 80.8097)
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    
    @State private var isProfileIsSubmit = false
    
    var body: some View {
       
        NavigationStack{
            
            VStack {
                VStack{
                    HStack{
                        Text("Edit Profile ")
                            .font(AppFont.largeBold)
                        Spacer()
                    }
                    .padding()
                    
                    
                    Button(action: {
                        isPickerShowing = true
                    }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable() // Call resizable on Image, not UIImage
                                .frame(width: 100, height: 100)
                                .cornerRadius(50.0)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 90, height: 90)
                                .cornerRadius(50.0)
                        }
                    }
                    .sheet(isPresented: $isPickerShowing , onDismiss: nil) {
                        ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
                    }
                }
//                .padding()
                
                List{
                    Section(header: CustomSectionHeader(title: "About").foregroundColor(.white)){
                        
                        // Name TextField
                        TextField("Name", text: $fullName)
                            .listRowBackground(Color.darkbg)
                        // About TextField
                        TextField("Bio", text: $about)
                            .listRowBackground(Color.darkbg)
                        //city
                        TextField("City", text: $city)
                            .listRowBackground(Color.darkbg)
                        
                        TextField("Occupation", text: $occupation)
                            .listRowBackground(Color.darkbg)
                    }
                    
                    Section(header: CustomSectionHeader(title: "Personal").foregroundColor(.white)){
                        //age
                        TextField("Age", text: $age)
                            .listRowBackground(Color.darkbg)
                        
                        // Email TextField
                        TextField("Email Address", text: $email)
                            .listRowBackground(Color.darkbg)
                            .autocapitalization(.none)
                    }
                    
                    Section(header: CustomSectionHeader(title: "Phone Number").foregroundColor(.white)){
                        // Password SecureField
                        TextField("PhoneNumber", value: $phoneNumber, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .listRowBackground(Color.darkbg)
                    }
                }
                .listStyle(.insetGrouped)
                .background(Color.background)
                .scrollContentBackground(.hidden)
                
                NavigationLink(destination: homepageComplete(), isActive: $isProfileIsSubmit) {
                    Button(action: {
                        // Handle add class action
                        viewModel.updateStudentProfile(fullName: fullName,
                                                       email: email,
                                                       aboutParagraph: about,
                                                       age: age,
                                                       city: city,
                                                       location: location,
                                                       occupation: occupation,
                                                       phoneNumber: phoneNumber ,
                                                       selectedImage: selectedImage)
                        // Activate the navigation to TeacherHomePage
                        
                        
                        isProfileIsSubmit = true
                    }) {
                        Text("Submit Profile")
                            .foregroundColor(.black)
                            .font(AppFont.mediumSemiBold)
                    }
                    .frame(width:250, height: 25)
                    .padding()
                    .background(Color.accent)
                    .cornerRadius(50)
                }
                
            } //v end
            .background(Color.background)
            
        } //nav stack end
        .navigationTitle("Edit Profile")
    }
        
    }





struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker1 = UIImagePickerController()
        imagePicker1.sourceType = .photoLibrary
        imagePicker1.delegate = context.coordinator
        
        return imagePicker1
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var parent: ImagePicker
    init(_ picker: ImagePicker){
        self.parent = picker
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Image selected")
        if let image = info[UIImagePickerController.InfoKey.originalImage] as?
            UIImage{
            DispatchQueue.main.async {
                self.parent.selectedImage = image
            }
        }
        parent.isPickerShowing = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
        parent.isPickerShowing = false
    }
}


#Preview {
    ProfileInputView()
    }



