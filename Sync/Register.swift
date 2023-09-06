import SwiftUI
import Firebase

struct Register: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isViewActive = false
    @State private var registrationSuccess = false
    
       @State private var showOnboarding = false

    func registerUser() {
           // Validate that text fields are not empty
           guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
               print("Please fill in all the fields")
               return
           }

           Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
               if let error = error {
                   print("Error creating user: \(error.localizedDescription)")
               } else {
                   // User registration successful
                   print("User registered successfully!")
                   
                   // Store user details in Firestore
                   let userData: [String: Any] = [
                       "username": username,
                       "email": email
                       // Add more user details if needed
                   ]
                   
                   let db = Firestore.firestore()
                   let userId = authResult?.user.uid ?? ""
                   db.collection("users").document(userId).setData(userData) { error in
                       if let error = error {
                           print("Error storing user data in Firestore: \(error.localizedDescription)")
                       } else {
                           print("User data stored in Firestore successfully!")
                           registrationSuccess = true // Set the registration success flag
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

                    TextField("", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
//                        .background(Color(.white))
                        .border(Color.white, width: 5)
                        .cornerRadius(10)
                        .foregroundColor(.white)
//                        .accentColor(.white)
                        .placeholder(when: username.isEmpty) {
                                Text("Username").foregroundColor(.white)
                                .padding()
                        }
                  

                    TextField("", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
//                        .background(Color(.white))
                        .border(Color.white, width: 5)
                        .cornerRadius(10)
                        .foregroundColor(.white)
//                        .accentColor(.white)
                        .placeholder(when: email.isEmpty) {
                                Text("Email").foregroundColor(.white)
                                .padding()
                        }

                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
//                        .background(Color(.white))
                        .border(Color.white, width: 5)
                        .cornerRadius(10)
                        .foregroundColor(.white)
//                        .accentColor(.white)
                        .placeholder(when: password.isEmpty) {
                                Text("Password").foregroundColor(.white)
                                .padding()
                        }

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
                                    registerUser() // Call the function to log in the user
                                }) {
                                    Text("Register")
                                        .foregroundColor(.white)
                                        .frame(width: 300, height: 50)
                                        .background(Color(.white))
                                        .cornerRadius(10)
                                }
                                .background(NavigationLink("", destination: OnBoardingOne(), isActive: $showOnboarding)) // Use showOnboarding here
                                .accentColor(.black)
                                .overlay(Text("Register").foregroundColor(.black), alignment: .center)
                                .disabled(email.isEmpty || password.isEmpty || username.isEmpty)

                 
                    
                    

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
