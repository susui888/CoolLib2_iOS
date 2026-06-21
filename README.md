# CoolLib iOS Client 

[![iOS UI Demo](https://img.shields.io/badge/iOS-UI_Demo-007AFF?style=flat&logo=apple&logoColor=white)](https://ryansu.uk/demo/ios-demo/)


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

## Decentralized Asset Pipeline

```mermaid id="p9k2sa"
---
config:
  theme: redux-color
  look: neo
---
sequenceDiagram

                participant UI as ImagePicker (UI)
                participant Repo as AssetRepository
                participant Web as Gateway (Spring)
                participant R2 as Cloudflare R2
                autonumber

                UI->>Repo: uploadImage(UIImage)

                rect rgb(240, 247, 255)
                Note over Repo, Web: Phase 1: Authentication & Ticket Fetch
                Repo->>Web: GET /assets/presigned-url (fileName)
                Web-->>Repo: 200 OK (PUT URL + Public URL)
                end

                rect rgb(240, 253, 244)
                Note over Repo, R2: Phase 2: Direct Binary Pipe to Edge
                Repo->>R2: HTTP PUT (Binary Data + Presigned URL)
                R2-->>Repo: 200 OK (Upload Success)
                end

                rect rgb(254, 242, 242)
                Note over Repo, Web: Phase 3: Distributed Metadata Sync
                Repo->>Web: POST /books/reviews (imageKey)
                Web-->>Repo: 201 Created
                end

                Repo-->>UI: Render Remote Image
    
