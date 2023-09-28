import SwiftUI
import Firebase

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.horizontal, 10)
//            .background(Color.white.opacity(0.2))
//            .cornerRadius(8)
            .foregroundColor(.white)
    }
}

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var wrongEmail = 0
    @State private var wrongPassword = 0
    @State private var isViewActive = false
    @State private var loginSuccess = false
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                if (error as NSError).code == AuthErrorCode.wrongPassword.rawValue {
                    wrongPassword = 1
                } else {
                    wrongEmail = 1
                }
            } else {
                print("Login successful!")
                loginSuccess = true
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
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .padding()
                        .frame(width: 300, height: 50)
                        .border(Color.white, width: 4)
//                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .padding()
                        .frame(width: 300, height: 50)
                        .border(Color.white, width: 4)
//                        .cornerRadius(10)
                    
                    Text("")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundColor(.white)
                    
                    Button(action: {
                        loginUser()
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color(.white))
                            .cornerRadius(10)
                    }
                    .background(NavigationLink("", destination: SyncTabView(), isActive: $loginSuccess))
                    .accentColor(.black)
                    .overlay(Text("Login").foregroundColor(.black), alignment: .center)
                    
                    Button("Create an account") {
                        isViewActive = true
                    }
                    .background(NavigationLink("", destination: Register(), isActive: $isViewActive))
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                }
            }
            .navigationBarHidden(true)
            
            
            
        }
    }
}
    
  

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
