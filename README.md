# CoolLib iOS

<p>
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343"/>&nbsp;
  <img src="https://img.shields.io/badge/SwiftUI-iOS_18%2B-0D96F6"/>&nbsp;
  <img src="https://img.shields.io/badge/SwiftData-Local_DB-F05138"/>&nbsp;
  <img src="https://img.shields.io/badge/Architecture-Clean_Architecture-4F5B66"/>
</p>

<p>
  <img src="https://img.shields.io/badge/Cloudflare-R2_Storage-orange"/>&nbsp;
  <img src="https://img.shields.io/badge/S3-Presigned_URLs-FF9900"/>&nbsp;
  <img src="https://img.shields.io/badge/Concurrency-Swift_6-5C6BC0"/>
</p>

iOS client for the CoolLib distributed library system. Built with Swift 6 and SwiftUI, designed around offline-first data persistence and direct-to-cloud asset delivery via Cloudflare R2.

---

## Ecosystem

* [CoolLib Server](https://github.com/susui888/CoolLeaf) — Spring Boot API & metadata engine
* [CoolLib Android](https://github.com/susui888/coollib-android) — Jetpack Compose client

---

## Tech Stack

### Presentation Layer

* SwiftUI
* Observation framework
* MVVM architecture

### Domain Layer

* Clean Architecture
* Protocol-oriented design
* Actor-based concurrency model

### Data Layer

* SwiftData (offline persistence)
* URLSession networking layer
* Repository pattern

### Cloud Infrastructure

* Cloudflare R2 object storage
* S3-compatible presigned upload pipeline
* Stateless backend integration (Spring Boot API)

---

## Capabilities

* Offline-first library management with local SwiftData persistence
* Secure asset upload pipeline using presigned URLs (no credential exposure)
* Real-time synchronization with Spring Boot backend
* Fully reactive UI using Observation framework
* Strict concurrency model with Swift 6 actors
* Decoupled architecture aligned with distributed backend system

---

## Architecture Overview

```mermaid id="p9k2sa"
flowchart LR
    UI(SwiftUI Views) --> VM(ViewModel)
    VM --> UseCase(Use Cases)
    UseCase --> Repo(Repository)
    Repo --> Local[(SwiftData)]
    Repo --> Remote(Spring API)
    Repo --> Storage(Cloudflare R2)

    %% UI layer
    style UI fill:#22c55e,stroke:#16a34a,color:#fff

    %% Domain layer
    style VM fill:#475569,stroke:#334155,color:#fff
    style UseCase fill:#475569,stroke:#334155,color:#fff
    style Repo fill:#475569,stroke:#334155,color:#fff

    %% Data layer
    style Local fill:#bfdbfe,stroke:#60a5fa,color:#1f2937

    %% Cloud layer
    style Remote fill:#3b82f6,stroke:#2563eb,color:#fff
    style Storage fill:#f59e0b,stroke:#d97706,color:#fff

    linkStyle default stroke:#94a3b8
