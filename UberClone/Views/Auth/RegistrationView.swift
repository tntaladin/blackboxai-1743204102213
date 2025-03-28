import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading) {
                Text("Create account")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Sign up to get started")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            // Input fields
            VStack(spacing: 16) {
                InputField(text: $fullname, title: "Full Name", placeholder: "Enter your full name")
                
                InputField(text: $email, title: "Email Address", placeholder: "name@example.com")
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                InputField(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                
                InputField(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
            }
            .padding(.horizontal)
            
            // Sign up button
            Button {
                Task {
                    do {
                        guard password == confirmPassword else {
                            alertMessage = "Passwords don't match"
                            showAlert = true
                            return
                        }
                        
                        try await authService.createUser(
                            withEmail: email,
                            password: password,
                            fullname: fullname
                        )
                    } catch {
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top)
            
            Spacer()
            
            // Sign in link
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthService())
    }
}