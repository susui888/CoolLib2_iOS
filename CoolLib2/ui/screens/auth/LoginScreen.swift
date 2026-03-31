import SwiftUI


struct LoginScreen: View {
    
    @EnvironmentObject var router: AppRouter

    @StateObject private var viewModel: UserViewModel


    init(
        container: AppContainer,
    ) {
        _viewModel = StateObject(
            wrappedValue: container.makeUserViewModel()
        )
    }
    
    
    var body: some View {
 
            LoginScreenContent(
                state: viewModel.loginState,
                
                onLogin: { username, password in
                    viewModel.login(username: username, password: password)
                }
            )
            .onChange(of: viewModel.loginState) { oldValue, newValue in
                
                if case .success(_) = newValue {
                    router.showLogin(false)
                }
            }
        }
}


struct LoginScreenContent: View {
    @State private var username = ""
    @State private var password = ""


    let state: AuthUIState<LoginResponse>
    let onLogin: (String, String) -> Void
    
    // MARK: - Computed Properties
    private var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    private var errorMessage: String? {
        if case .error(let msg) = state { return msg }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 32) {
            
            // Header Section
            VStack(spacing: 12) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)
                Text("CoolLib").font(.largeTitle).fontWeight(.bold)
                Text("Books on the Move").foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Input Section
            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            
            // Login Button
            Button {
                guard !username.isEmpty, !password.isEmpty else { return }
                onLogin(username, password)
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(username.isEmpty || password.isEmpty || isLoading)
            
            // Footer Section
            VStack(spacing: 8) {
                Button("Forgot Password") { }
                
                Button {
                    // TODO: Trigger register navigation
                } label: {
                    Text("Create Account")
                }
            }
            .font(.footnote)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Initial State") {
    NavigationStack {
        LoginScreenContent(state: .idle) { username, password in
            print("Login tapped with: \(username)")
        }
    }
}

#Preview("Loading State") {
    NavigationStack {
        LoginScreenContent(state: .loading) { _, _ in }
    }
}

#Preview("Error State") {
    NavigationStack {
        LoginScreenContent(state: .error("Invalid username or password")) { _, _ in }
    }
}

#Preview("Success State") {
    NavigationStack {
        LoginScreenContent(
            state: .success(LoginResponse(token: "mock_token", username: "Ryan Su"))
        ) { _, _ in }
    }
}
