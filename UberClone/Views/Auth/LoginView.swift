import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Create a local account to try the ride-booking demo.")
                        .foregroundStyle(.secondary)
                }
                Section("Sign in") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.username)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                    Button(action: signIn) {
                        HStack {
                            Text("Sign in")
                            Spacer()
                            if isSubmitting { ProgressView() }
                        }
                    }.disabled(isSubmitting || email.isEmpty || password.isEmpty)
                }
                Section {
                    NavigationLink("Create an account") { RegistrationView() }
                }
            }
            .navigationTitle("Welcome back")
            .alert("Could not sign in", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                    Button("OK") { errorMessage = nil }
                } message: { Text(errorMessage ?? "") }
        }
    }

    private func signIn() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            do { try await authService.login(withEmail: email, password: password) }
            catch { errorMessage = error.localizedDescription }
        }
    }
}
