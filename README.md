# 🤝 Stick Together

> **Stick Together** is a minimalist social habit-tracking app built with **SwiftUI**.  
> The goal: help people stay consistent with habits by doing challenges **together**.

---

## 🚀 Project Overview

This repository contains the **base architecture and initial login flow** for the app.  
Built with **SwiftUI + MVVM** and a simple dependency injection setup, it’s designed for clean scalability as new features (friends, challenges, tracking) are added.

---

## 🧱 Architecture

The app follows the **MVVM + Coordinator** pattern with light **Dependency Injection (DI)**.

```
AppEntry.swift → AppCoordinatorView → (LoginView / MainTabView)
           ↓
        DIContainer
           ↓
      AuthServiceProtocol
           ↓
     MockAuthService (Phase 0)
```

**Layers overview:**

| Layer | Responsibility |
|-------|----------------|
| **View (SwiftUI)** | Declarative UI, binds to ViewModel |
| **ViewModel (ObservableObject)** | Handles UI logic, state, async actions |
| **Services** | Networking, Auth, Persistence, Notifications |
| **Models** | Simple `Codable` structs for app data |
| **DIContainer** | Registers dependencies (e.g. AuthService) |

---

## 📂 Project Structure

```
StickTogether/
 ├─ App/
 │   └─ AppEntry.swift
 ├─ Core/
 │   ├─ DIContainer.swift
 │   └─ Models/
 │       └─ User.swift
 ├─ Features/
 │   ├─ Auth/
 │   │   ├─ LoginView.swift
 │   │   ├─ AuthViewModel.swift
 │   │   └─ Services/
 │   │       ├─ AuthServiceProtocol.swift
 │   │       └─ MockAuthService.swift
 │   └─ AppCoordinatorView.swift
 └─ README.md
```

---

## 🧰 Current Functionality (Phase 0)

✅ **Dependency Injection setup** (`DIContainer`)  
✅ **Coordinator view** switching between Login and Main screens  
✅ **Mock authentication flow** — any non-empty email/password works  
✅ **Login screen UI** (Get Started + Stick Together)  
✅ **Basic ViewModel structure**

---

## 🧭 Roadmap

### 🩵 Phase 1 — Authentication
- Replace `MockAuthService` with Firebase Auth
- Add user registration and persistent login

### 💬 Phase 2 — Core Features
- Friends list (add, accept, remove)
- Shared challenges system
- Daily progress tracking (streaks)

### 🔔 Phase 3 — Notifications & Realtime
- Local reminders
- Push notifications for friend activity

### 🚀 Phase 4 — CI/CD & Release
- Unit + UI tests
- GitHub Actions + TestFlight deployment

---

## 🧩 Tech Stack

| Component | Technology |
|------------|-------------|
| **UI** | SwiftUI |
| **Architecture** | MVVM + Coordinator |
| **Concurrency** | Swift Concurrency (async/await) |
| **Dependency Injection** | Simple DIContainer |
| **Backend (planned)** | Firebase |
| **Persistence (planned)** | CoreData |
| **Notifications (planned)** | UNUserNotificationCenter + APNs |

---

## Figma Design
[View the interactive design in Figma](https://www.figma.com/design/BHNAYWaEGcwYoomamDRHov/StickTogether?node-id=0-1&p=f&t=rHmoWV57zxbApQAS-0)

---

## App Design

### 1. Splash Screen
<img width="375" height="812" alt="Splash" src="https://github.com/user-attachments/assets/550d028c-4611-442e-85c5-e10bcdda7c4b" />

### 2. Login View
<img width="375" height="812" alt="LogIn View" src="https://github.com/user-attachments/assets/385155e6-22b7-42ae-af06-ac6088c8deec" />

### 3. Register View
<img width="375" height="812" alt="Register View" src="https://github.com/user-attachments/assets/760fca13-3b54-4701-8399-50345a3caf83" />

### 4. Home Screen
<img width="375" height="812" alt="Home Screen" src="https://github.com/user-attachments/assets/08be61fb-f5da-4b8d-8757-78f27948380d" />

### 5. Create Habit
<img width="375" height="812" alt="Create Habit" src="https://github.com/user-attachments/assets/ede07b84-95df-47be-bd26-b972d6e5b65b" />

### 6. Habit View
<img width="375" height="812" alt="Habit View" src="https://github.com/user-attachments/assets/10cee9d4-8ba4-4efd-9f0d-0112ab821e5b" />

## 🏁 Getting Started

### 1️⃣ Clone the project
```bash
git clone https://github.com/Gr33nEight/StickTogetherIOS.git
cd stick-together
```

### 2️⃣ Open in Xcode
Open `StickTogether.xcodeproj`.

### 3️⃣ Run on Simulator
Just hit **Run ▶️** — the mock login flow works out of the box.

---

## 👤 Author
**Natanael Jop**  
iOS Developer | Swift / SwiftUI / Firebase
