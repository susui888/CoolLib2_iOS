//
//  TopBarView.swift
//  CoolLib2
//
//  Created by susui on 2026/3/30.
//

import SwiftUI

@MainActor
@Observable
class TopBarManager {
    var showProfileSheet = false
    var showScanner = false

    var container: AppContainer?
    var router: AppRouter?


    var isLoggedIn: Bool {
        //container?.authState.isLoggedIn ?? false
        false
    }

    var username: String? {
        //container?.authState.username
        ""
    }


    func handleScan() {
        print("Starting QR Scanner...")
        showScanner = true
    }

    func handleMenuTap(_ identifier: String) {
        showProfileSheet = false
        if identifier == "login" {
            self.router?.navigate(fromMenu: identifier)
        } else {

        }
    }

    func handleLogout() {
        showProfileSheet = false
        // container?.logout()
    }
}

extension View {
    func topBar(manager: TopBarManager) -> some View {
        self.modifier(
            TopBarView(
                onScan: { manager.handleScan() },
                onLogout: { manager.handleLogout() },
                isLoggedIn: manager.isLoggedIn,
                username: manager.username,
                onMenuTap: { id in manager.handleMenuTap(id) }
            )
        )
        .fullScreenCover(isPresented: createBinding(manager)) {
            Text("Scanner Placeholder")  // ScannerView()
        }
    }

    private func createBinding(_ manager: TopBarManager) -> Binding<Bool> {
        Binding(
            get: { manager.showScanner },
            set: { manager.showScanner = $0 }
        )
    }
}

struct TopBarView: ViewModifier {

    let onScan: () -> Void
    let onLogout: () -> Void
    let isLoggedIn: Bool
    let username: String?
    let onMenuTap: (String) -> Void

    @State private var showProfileSheet = false

    func body(content: Content) -> some View {
        content
            .navigationTitle("CoolLib")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button(action: onScan) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title2)
                    }

                    Button(action: { showProfileSheet.toggle() }) {
                        Image("User")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showProfileSheet) {
                NavigationStack {
                    MenuView(
                        isLoggedIn: isLoggedIn,
                        username: username,
                        onMenuTap: { id in
                            showProfileSheet = false
                            onMenuTap(id)
                        },
                        onLogout: {
                            showProfileSheet = false
                            onLogout()
                        }
                    )
                }
                .presentationDragIndicator(.visible)
            }
    }
}

#Preview("Not Login") {
    NavigationStack {
        Color.clear
            .modifier(
                TopBarView(
                    onScan: {},
                    onLogout: {},
                    isLoggedIn: false,
                    username: nil,
                    onMenuTap: { _ in }
                )
            )
    }
}

#Preview("Login") {
    NavigationStack {
        Color.clear
            .modifier(
                TopBarView(
                    onScan: {},
                    onLogout: {},
                    isLoggedIn: true,
                    username: "Ryan Su",
                    onMenuTap: { _ in }
                )
            )
    }
}
