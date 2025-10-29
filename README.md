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
[View the interactive design in Figma]([https://www.figma.com/file/XXXXXX/StickTogether](https://www.figma.com/design/BHNAYWaEGcwYoomamDRHov/StickTogether?node-id=0-1&p=f&t=rHmoWV57zxbApQAS-0))

---

## App Design

### 1. Splash Screen
A welcoming screen shown when the app launches.
![Splash Screen](Resources/Design/SplashScreen.png)

### 2. Login View
Allows users to sign in using their email and password.
![Login View](Resources/Design/LoginView.png)

### 3. Register View
Enables new users to create an account and join the Stick Together community.
![Register View](Resources/Design/RegisterView.png)

### 4. Home Screen
Main dashboard showing active habits, challenges, and user overview.
![Home Screen](Resources/Design/HomeScreen.png)

### 5. Create Habit
Screen for creating a new habit, including name, frequency, and optional reminders.
![Create Habit](Resources/Design/CreateHabit.png)

### 6. Habit View
Displays detailed information about a specific habit, progress tracking, and editing options.
![Habit View](Resources/Design/HabitView.png)

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
