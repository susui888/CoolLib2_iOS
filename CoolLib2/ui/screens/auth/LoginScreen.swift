import SwiftUI

struct LoginScreen: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    
    let onLogin: (String, String) -> Void
    
    
    var body: some View{
        VStack(spacing: 32){
            
            VStack(spacing: 12){
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)
                
                Text("CoolLib")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Books on the Move")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            
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
            }
            
            Button {
                
                guard !username.isEmpty, !password.isEmpty else { return }
                
                isLoading = true
                
                onLogin(username,password)
                
            }label: {
                
                if (isLoading){
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
            .disabled(username.isEmpty || password.isEmpty)
            
            VStack(spacing: 8){
                Button("Forgot Passward"){}
                
                Button{
                    
                }label: {
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

#Preview {
    NavigationStack {
        LoginScreen(){ _, _ in }
    }
}
