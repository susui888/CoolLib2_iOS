//
//  ScannerScreen.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/4/3.
//

import SwiftUI

struct ScannerScreen: View {
    @Bindable var manager: TopBarManager

    @StateObject private var viewModel: ScannerViewModel

    init(
        container: AppContainer,
        manager: TopBarManager
    ) {
        _viewModel = StateObject(
            wrappedValue: container.makeScannerViewModel()
        )
        self.manager = manager
    }

    var body: some View {
        ScannerScreenContent(
            manager: manager,
            viewModel: viewModel
        )
    }
}

struct ScannerScreenContent: View {
    @Bindable var manager: TopBarManager

    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        ZStack {

            ISBNScannerView { scannedCode in
                
                manager.lastScannedISBN = scannedCode
                
                viewModel.processIsbn(scannedCode)
            }
            .ignoresSafeArea()

            scanningReticle

            if viewModel.uiState.isLoading {
                ProgressView()
                    .tint(.white)
                    .padding(.bottom, 80)
            } else if !manager.lastScannedISBN.isEmpty {
                resultOverlay
            }

            closeButton
        }
        .onChange(of: viewModel.uiState.shouldNavigateToCart) { oldValue, newValue in
            if newValue {
                manager.navigateToCart()

                viewModel.resetNavigation()
            }
        }
    }

    // MARK: - Subviews 
    private var scanningReticle: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                viewModel.uiState.isLoading
                    ? Color.blue : Color.white.opacity(0.5),
                lineWidth: 2
            )
            .frame(width: 280, height: 200)
            .overlay {
                Image(systemName: "viewfinder")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
            }
    }

    private var resultOverlay: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text(
                    viewModel.uiState.detectedBookTitle != nil
                        ? "Book Added" : "ISBN Detected"
                )
                .font(.caption)
                .foregroundColor(.secondary)

                Text(
                    viewModel.uiState.detectedBookTitle
                        ?? manager.lastScannedISBN
                )
                .font(.system(.title3, design: .serif))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

                if let error = viewModel.uiState.error {
                    Text(error).font(.caption2).foregroundColor(.red)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.bottom, 80)
        }
        .animation(.spring(), value: manager.lastScannedISBN)
    }

    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    manager.showScanner = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(
                            .white.opacity(0.6),
                            .ultraThinMaterial
                        )
                        .padding()
                }
            }
            Spacer()
        }
    }
}

struct ISBNScannerView: UIViewControllerRepresentable {

    var didFindCode: (String) -> Void

    func makeUIViewController(context: Context) -> ISBNScannerViewController {
        let viewController = ISBNScannerViewController()

        viewController.completionHandler = didFindCode
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: ISBNScannerViewController,
        context: Context
    ) {}
}
