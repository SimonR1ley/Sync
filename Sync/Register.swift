import SwiftUI
import Firebase


struct CustomTextFieldStyleRegister: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.horizontal, 10)
//            .background(Color.white.opacity(0.2))
//            .cornerRadius(8)
            .foregroundColor(.white)
    }
}

struct Register: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isViewActive = false
    @State private var registrationSuccess = false
    
       @State private var showOnboarding = false

    func registerUser() {
           guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
               print("Please fill in all the fields")
               return
           }

           Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
               if let error = error {
                   print("Error creating user: \(error.localizedDescription)")
               } else {
                   print("User registered successfully!")
                   
                   let userData: [String: Any] = [
                       "username": username,
                       "email": email
                   ]
                   
                   let db = Firestore.firestore()
                   let userId = authResult?.user.uid ?? ""
                   db.collection("users").document(userId).setData(userData) { error in
                       if let error = error {
                           print("Error storing user data in Firestore: \(error.localizedDescription)")
                       } else {
                           print("User data stored in Firestore successfully!")
                           registrationSuccess = true
                       }
                   }
               }
           }
       }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 216/255, green: 67/255, blue: 57/255)
                    .ignoresSafeArea()

                VStack {
                    Image("authlogo")
                        .resizable()
                        .frame(width: 160, height: 140)

                    Text("")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundColor(.white)

//                    TextField("", text: $username)
//                        .padding()
//                        .frame(width: 300, height: 50)
////                        .background(Color(.white))
//                        .border(Color.white, width: 5)
////                        .cornerRadius(10)
//                        .foregroundColor(.white)
////                        .accentColor(.white)
//                        .placeholder(when: username.isEmpty) {
//                                Text("Username").foregroundColor(.white)
//                                .padding()
//                        }
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(CustomTextFieldStyleRegister())
                        .padding()
                        .frame(width: 300, height: 50)
                        .border(Color.white, width: 4)
//                        .cornerRadius(10)
                  

//                    TextField("", text: $email)
//                        .padding()
//                        .frame(width: 300, height: 50)
////                        .background(Color(.white))
//                        .border(Color.white, width: 5)
////                        .cornerRadius(10)
//                        .foregroundColor(.white)
////                        .accentColor(.white)
//                        .placeholder(when: email.isEmpty) {
//                                Text("Email").foregroundColor(.white)
//                                .padding()
//                        }
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyleRegister())
                        .padding()
                        .frame(width: 300, height: 50)
                        .border(Color.white, width: 4)
//                        .cornerRadius(10)

                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyleRegister())
                        .padding()
                        .frame(width: 300, height: 50)
                        .border(Color.white, width: 4)
//                        .cornerRadius(10)

                    Text("")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundColor(.white)

//                    Button("Register") {
//                        registerUser() // Call the function to register the user
//                    }
//                    .foregroundColor(.white)
//                    .frame(width: 300, height: 50)
//                    .background(Color("SplashBackground"))
//                    .cornerRadius(10)
//                    .disabled(email.isEmpty || password.isEmpty || username.isEmpty) // Disable button if fields are empty
//
                    
                    
                    Button(action: {
                        registerUser()
                        showOnboarding = true // Activate the showOnboarding state when the registration is successful
                    }) {
                        Text("Register")
                            .foregroundColor(.black)
                            .frame(width: 300, height: 50)
                            .background(Color(.white))
                            .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty || username.isEmpty)

                    // Use the NavigationLink separately to navigate to the onboarding screen when showOnboarding is true.
                    NavigationLink("", destination: OnBoardingOne(), isActive: $showOnboarding)
                        .opacity(0) // Hide the link, but it will trigger navigation when showOnboarding is true


                 
                    
                    

                    Button("Already have an account") {
                        isViewActive = true
                    }
                    .background(NavigationLink("", destination: Login(), isActive: $isViewActive))
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                }

                NavigationLink(
                    destination: OnBoardingOne (),
                    isActive: $registrationSuccess,
                    label: {
                        EmptyView()
                    }
                )
            }
        }
        .navigationBarHidden(true)
    }
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register()
    }
}
