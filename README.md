# CoolLib iOS

The premium iOS client for the CoolLib ecosystem, engineered for high-performance library management. This implementation leverages **Swift 6** and **Cloudflare R2** to deliver a secure, decentralized, and offline-first experience.

## Ecosystem Links
* [CoolLib Server](https://github.com/susui888/CoolLeaf) - Spring Boot API & Metadata Engine
* [CoolLib Android](https://github.com/susui888/coollib-android) - Jetpack Compose Counterpart

## Tech Stack
* **UI Framework:** SwiftUI + Observation Framework
* **Architecture:** Clean Architecture (MVVM) & Protocol-Oriented Programming
* **Storage:** SwiftData (Local Persistence) & **Cloudflare R2 (Object Storage)**
* **Networking:** URLSession + **S3 Presigned URLs**
* **Concurrency:** Swift 6 Structured Concurrency (Async/Await)

## Key Features
* **Secure Asset Pipeline:** Implements a direct-to-cloud upload flow using **S3-compatible R2 storage**, eliminating backend bottlenecks and protecting credentials via **Presigned URLs**.
* **Modern Concurrency:** Fully utilizes **Swift 6 strict concurrency** and Actors to ensure thread-safe data mapping and UI consistency.
* **Offline-First Strategy:** Seamlessly synchronizes local **SwiftData** entities with the distributed Spring backend, ensuring full functionality without an active connection.
* **Reactive UI:** Leverages the **Observation** framework for high-frequency UI updates and state management across complex views.

## High-Level Architecture
The app follows **Clean Architecture** principles to decouple business logic from framework-specific code:
1. **Domain:** Entities and Use Cases (Business Logic).
2. **Data:** Repositories handling the logic between SwiftData, Spring API, and R2 Storage.
3. **Presentation:** SwiftUI views observing view models for real-time state updates.

## Requirements
* **iOS 18.0+** (Required for SwiftData & Observation)
* **Xcode 16.0+** (Required for Swift 6)
* **Swift 6.0**

