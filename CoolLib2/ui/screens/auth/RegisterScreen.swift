//
//  RegisterScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/5/12.
//

import SwiftUI

struct RegisterScreen: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: UserViewModel
    private let telemetryUseCase: TelemetryUseCase
    
    init(container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: container.makeUserViewModel()
        )
        self.telemetryUseCase = container.telemetryUseCase
    }

    var body: some View {
        RegisterScreenContent(
            registerState: viewModel.registerState,
            loginState: viewModel.loginState,
            onRegister: { username, password, email in
                viewModel.register(username: username, password: password, email: email)
            }
        )
        .onChange(of: viewModel.loginState) { _, newState in
            if case .success(_) = newState {
                router.showLogin(false)
                viewModel.resetStates()
            }
        }
        .trackScreen(name: TelemetryEvents.Screens.register, with: telemetryUseCase)
    }
}

struct RegisterScreenContent: View {
    // MARK: - Local Input State
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""

    // MARK: - Props
    let registerState: AuthUIState<String>
    let loginState: AuthUIState<LoginResponse>
    let onRegister: (String, String, String) -> Void

    // MARK: - Computed Properties
    private var isUsernameValid: Bool { username.count >= 3 }
    private var isPasswordValid: Bool { password.count >= 6 }
    private var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private var isLoading: Bool {
        if case .loading = registerState { return true }
        if case .loading = loginState { return true }
        return false
    }

    private var errorMessage: String? {
        if case .error(let msg) = registerState { return msg }
        if case .error(let msg) = loginState { return msg }
        return nil
    }

    private var canRegister: Bool {
        isUsernameValid && isPasswordValid && isEmailValid && !isLoading
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header (保持与 LoginScreen 风格一致)
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                    Text("Join CoolLib").font(.largeTitle).fontWeight(.bold)
                    Text("Start your reading journey").foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Input Section
                VStack(spacing: 16) {
                    inputField(title: "Username", text: $username, isError: !isUsernameValid && !username.isEmpty, errorMsg: "At least 3 characters")
                    
                    inputField(title: "Password", text: $password, isError: !isPasswordValid && !password.isEmpty, errorMsg: "At least 6 characters", isSecure: true)
                    
                    inputField(title: "Email", text: $email, isError: !isEmailValid && !email.isEmpty, errorMsg: "Invalid email format", keyboardType: .emailAddress)


                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }
                }

                // Register Button
                Button {
                    onRegister(username, password, email)
                } label: {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canRegister)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func inputField(
        title: String,
        text: Binding<String>,
        isError: Bool,
        errorMsg: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if isSecure {
                    SecureField(title, text: text)
                } else {
                    TextField(title, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isError ? Color.red : Color.clear, lineWidth: 1)
            )

            if isError {
                Text(errorMsg)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Previews
#Preview("Register Initial") {
    NavigationStack {
        RegisterScreenContent(registerState: .idle, loginState: .idle) { _, _, _ in }
    }
}

#Preview("Register Loading") {
    NavigationStack {
        RegisterScreenContent(registerState: .loading, loginState: .idle) { _, _, _ in }
    }
}

#Preview("Register Error") {
    NavigationStack {
        RegisterScreenContent(
            registerState: .error("Email already in use"),
            loginState: .idle
        ) { _, _, _ in }
    }
}
