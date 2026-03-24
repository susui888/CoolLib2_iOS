# CoolLib - Library Management iOS App

**CoolLib** is a high-performance library management app built with **SwiftUI** and **Clean Architecture**. It mirrors the Android version's architecture and features while leveraging modern iOS technologies.

## 🚀 Key Technical Wins

- **Architecture**: Implemented **Clean Architecture (MVVM)** with strict layer separation, ensuring high modularity and testability.
- **Concurrency**: Utilized **Swift Structured Concurrency (Async/Await)** for efficient, non-blocking data fetching and parallel mapping.
- **Data Persistence**: Leveraging **SwiftData** for modern, declarative local storage and seamless data syncing.
- **Reactive UI**: Built a fluid UI using **SwiftUI** and **Combine**, ensuring real-time state synchronization across all views.
- **Testing**: Robust test suite using **XCTest** (or Swift Testing) covering core business logic and repository mapping.

## 🛠 Tech Stack

- **UI**: SwiftUI, SF Symbols, Custom ViewModifiers.
- **Logic**: MVVM, Use Cases, Async/Await, Combine.
- **Data**: URLSession, SwiftData, Codable.

## 📊 Core Features

- **Loan Tracking**: Filtered views for "Active Loans" vs. "History" with status-based design.
- **Smart Stats**: Real-time calculation of "Due Soon" and "Overdue" metrics.
- **QR Scanning**: Integrated AVFoundation for instant book barcode/QR identification.
- **Book-Style UI**: Custom SwiftUI theme with a paper-like palette and signature book-texture card components.

## 🏗 Development
- **Min iOS**: 17.0
- **Build**: Xcode / Swift Package Manager
