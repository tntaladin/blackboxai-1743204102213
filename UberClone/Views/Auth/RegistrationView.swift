import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var fullname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Your details") {
                TextField("Full name", text: $fullname).textContentType(.name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.username)
                SecureField("Password (8+ characters)", text: $password)
                    .textContentType(.newPassword)
                SecureField("Confirm password", text: $confirmPassword)
                    .textContentType(.newPassword)
            }
            Section {
                Button(action: register) {
                    HStack {
                        Text("Create account")
                        Spacer()
                        if isSubmitting { ProgressView() }
                    }
                }.disabled(isSubmitting || fullname.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            } footer: {
                Text("Demo accounts stay on this device. Use a test password, not one you use elsewhere.")
            }
        }
        .navigationTitle("Create account")
        .alert("Could not create account", isPresented: Binding(
            get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
    }

    private func register() {
        guard !isSubmitting else { return }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            do {
                try await authService.createUser(withEmail: email, password: password, fullname: fullname)
            } catch { errorMessage = error.localizedDescription }
        }
    }
}
