import SwiftUI
import Firebase

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var wrongEmail = 0
    @State private var wrongPassword = 0
    @State private var isViewActive = false
    @State private var loginSuccess = false // Added state for successful login

    // Function to perform user login using Firebase Authentication
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                // Set states to show incorrect email or password
                if (error as NSError).code == AuthErrorCode.wrongPassword.rawValue {
                    wrongPassword = 1
                } else {
                    wrongEmail = 1
                }
            } else {
                // Login successful
                print("Login successful!")
                loginSuccess = true // Set login success flag
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

                    TextField("", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
//                        .background(Color(.white))
                        .border(Color.white, width: 5)
                        .cornerRadius(10)
                        .border(Color.red, width: CGFloat(wrongEmail))
                        .foregroundColor(.white)
//                        .accentColor(.white)
                        .placeholder(when: email.isEmpty) {
                                Text("Email").foregroundColor(.white)
                                .padding()
                        }
                    
                    SecureField("", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .border(Color.white, width: 5)
//                        .background(Color(.white))
                        .cornerRadius(10)
                        .border(Color.red, width: CGFloat(wrongPassword))
                        .accentColor(.black)
                        .foregroundColor(.white)
                        .placeholder(when: password.isEmpty) {
                                Text("Password").foregroundColor(.white)
                                .padding()
                        }

                    Text("")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundColor(.white)

                    Button(action: {
                        loginUser() // Call the function to log in the user
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color(.white))
                            .cornerRadius(10)
                    }
                    .background(NavigationLink("", destination: HealthViewScreen(), isActive: $loginSuccess))
                    .accentColor(.black)
                    .overlay(Text("Login").foregroundColor(.black), alignment: .center) // Add placeholder text to the button label

                    Button("Create an account") {
                        isViewActive = true
                    }
                    .background(NavigationLink("", destination: Register(), isActive: $isViewActive))
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
