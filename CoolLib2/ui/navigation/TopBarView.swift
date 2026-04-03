//
//  TopBarView.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/30.
//

import SwiftUI

@MainActor
@Observable
class TopBarManager {
    var showProfileSheet = false
    var showScanner = false

    var lastScannedISBN: String = ""

    let container: AppContainer
    let router: AppRouter

    init(container: AppContainer, router: AppRouter) {
        self.container = container
        self.router = router
    }

    var isLoggedIn: Bool {
        container.sessionManager.isLoggedIn
    }

    var username: String? {
        isLoggedIn ? container.sessionManager.getUsername() : nil
    }

    func handleScan() {
        lastScannedISBN = ""
        showScanner = true
    }

    func handleMenuTap(_ option: MenuOption) {
        showProfileSheet = false
        if option == .login {
            self.router.showLogin(true)
        } else {
            self.router.navigate(fromMenu: option)
        }
    }

    func handleLogout() {
        showProfileSheet = false

        container.sessionManager.clearSession()

        router.switchTo(tab: .home)
    }

    func navigateToCart() {
        self.showScanner = false
        self.router.switchTo(tab: .cart)
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
                onMenuTap: { option in manager.handleMenuTap(option) }
            )
        )
        .fullScreenCover(isPresented: createBinding(manager)) {
            ScannerScreen(container: manager.container, manager: manager)
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
    let onMenuTap: (MenuOption) -> Void

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
                        onMenuTap: { option in
                            showProfileSheet = false
                            onMenuTap(option)
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
