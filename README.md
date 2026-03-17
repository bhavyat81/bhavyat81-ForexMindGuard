# ForexMindGuard 🧠🛡️

> **The world's first forex trading companion that combines Emotion AI + AI Market Intelligence into one app.**

[![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue?logo=apple)](https://developer.apple.com/ios/)
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)](https://swift.org)
[![watchOS 10+](https://img.shields.io/badge/watchOS-10%2B-lightgrey?logo=apple)](https://developer.apple.com/watchos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📋 Table of Contents

- [App Overview](#app-overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [API Keys](#api-keys)
- [Development Roadmap](#development-roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## App Overview

ForexMindGuard solves the **#1 reason traders lose money — emotions**. It combines two powerful AI systems into one seamless iOS + Apple Watch experience:

1. **🧠 Emotion AI Guardian** — Real-time heart rate, facial expression, and behavioural analysis that auto-locks trading when you're too stressed to trade safely.
2. **🤖 AI "Why Did It Move?" Explainer** — When a currency pair makes a big move, the AI instantly explains *why* in plain English, citing real news sources.
3. **🛡️ Smart Shield** — When both systems activate simultaneously (high stress + big market move), a combined overlay pauses trading and shows you the full picture.

---

## Features

### 🧠 Emotion AI Guardian
- **Heart rate monitoring** via Apple Watch / HealthKit with real-time BPM streaming
- **Facial expression analysis** via ARKit TrueDepth camera — detects stress, fear, greed, excitement using 52 blend shapes
- **Behavioural pattern detection** — rapid trading, revenge trading, excessive screen tapping
- **Composite Stress Score** (0–100) combining all signals with a weighted formula:

```
Stress Score = (Heart Rate × 0.35) + (Facial × 0.30) + (Behaviour × 0.20) + (Time-of-Day × 0.15)

Score > 70  → ⚠️  Warning alert
Score > 85  → 🔒  Trading LOCKED + cooldown timer
```

- **Auto-lock** with configurable cooldown (default 15 minutes)
- **Override** with double confirmation + logging for session review
- **Lock history** and session analytics

### 🤖 AI "Why Did It Move?" Explainer
- **WebSocket-based** live forex price streaming (TraderMade / Finage)
- **Significant move detection** — configurable pip threshold over configurable time window
- **News fetching** from NewsAPI / Alpha Vantage News Sentiment
- **GPT-4 explanation** in plain English with structured output
- **Sentiment tagging** (📈 Bullish / 📉 Bearish / ⚖️ Neutral) with confidence score
- **Clickable sources** — every explanation cites real news articles

### 🛡️ Smart Shield
- Activates when **BOTH** systems trigger simultaneously
- Shows: current stress score + emotion + market move explanation + countdown timer
- Recommendations for what to do while waiting
- "Read Full Explanation" → detailed AI analysis view
- Double-confirmed override option

### ⌚ Apple Watch Companion
- Live BPM display with elevated heart rate alerts
- Glanceable stress/emotion widget
- Haptic alerts for trading locks
- Sends heart rate to iPhone via WatchConnectivity

---

## Screenshots

| Dashboard | Emotion Monitor | AI Explainer | Smart Shield |
|-----------|----------------|--------------|--------------|
| *(coming soon)* | *(coming soon)* | *(coming soon)* | *(coming soon)* |

---

## Architecture

ForexMindGuard follows a **Feature-based MVVM architecture** with Combine for reactive data flow:

```
┌─────────────────────────────────────────────────────┐
│                    SwiftUI Views                     │
│  DashboardView  EmotionMonitorView  MarketExplainer │
└──────────────────────┬──────────────────────────────┘
                       │ @Published / @EnvironmentObject
┌──────────────────────▼──────────────────────────────┐
│                  ViewModels (MVVM)                   │
│  DashboardVM  EmotionMonitorVM  TradingGuardVM      │
└──────────────────────┬──────────────────────────────┘
                       │ Combine Publishers
┌──────────────────────▼──────────────────────────────┐
│                    Core Services                     │
│                                                      │
│  EmotionAI:                                         │
│    HeartRateService → StressCalculator              │
│    FaceTrackingService ↗                            │
│    BehaviorAnalyzer ↗                               │
│    → TradingLockManager                             │
│                                                      │
│  MarketData:                                        │
│    ForexWebSocketService → PriceAlertService        │
│    → AIExplainerService                             │
│         ↳ NewsAPIService                            │
│         ↳ SentimentAnalyzer                         │
└──────────────────────┬──────────────────────────────┘
                       │ WatchConnectivity
┌──────────────────────▼──────────────────────────────┐
│               Apple Watch (watchOS)                  │
│    HeartRateMonitorView  QuickEmotionView            │
│    WatchConnectivityService                         │
└─────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI (iOS 17+) |
| Reactive | Combine |
| Health Data | HealthKit |
| Face Tracking | ARKit (ARFaceTrackingConfiguration) |
| ML | CoreML (emotion classifier — TODO: train model) |
| Charts | Swift Charts |
| WebSocket | URLSessionWebSocketTask (built-in) |
| Market Data | TraderMade / Alpha Vantage / Finage |
| News | NewsAPI.org / Alpha Vantage News |
| AI Explainer | OpenAI GPT-4o |
| Sentiment NLP | Apple NaturalLanguage framework |
| Watch | WatchKit + WatchConnectivity |
| Package Manager | Swift Package Manager |

---

## Project Structure

```
ForexMindGuard/
├── Package.swift                          # SPM dependencies (Starscream, OpenAI)
├── .gitignore                             # Xcode / Swift gitignore
├── README.md                              # This file
│
├── ForexMindGuard/
│   ├── App/
│   │   ├── ForexMindGuardApp.swift        # @main entry, tab navigation
│   │   └── AppDelegate.swift              # Push notifications, HK background delivery
│   │
│   ├── Core/
│   │   ├── Models/                        # Codable data models with sample data
│   │   │   ├── EmotionState.swift         # EmotionState enum + EmotionSnapshot
│   │   │   ├── HeartRateReading.swift     # BPM + zones + stress factor
│   │   │   ├── ForexPair.swift            # Live pair with derived pip calculations
│   │   │   ├── PriceMovement.swift        # Significant movement event
│   │   │   ├── NewsExplanation.swift      # AI explanation + sentiment + sources
│   │   │   ├── TradingSession.swift       # Session analytics + lock history
│   │   │   └── UserSettings.swift         # Persisted user preferences
│   │   │
│   │   ├── Services/
│   │   │   ├── EmotionAI/                 # Emotion detection pipeline
│   │   │   │   ├── HeartRateService.swift
│   │   │   │   ├── FaceTrackingService.swift
│   │   │   │   ├── EmotionClassifier.swift
│   │   │   │   ├── StressCalculator.swift
│   │   │   │   ├── BehaviorAnalyzer.swift
│   │   │   │   └── TradingLockManager.swift
│   │   │   ├── MarketData/                # Live market data pipeline
│   │   │   │   ├── ForexWebSocketService.swift
│   │   │   │   ├── PriceAlertService.swift
│   │   │   │   ├── CurrencyPairManager.swift
│   │   │   │   └── ForexAPIClient.swift
│   │   │   ├── NewsAI/                    # AI explanation pipeline
│   │   │   │   ├── NewsAPIService.swift
│   │   │   │   ├── AIExplainerService.swift
│   │   │   │   └── SentimentAnalyzer.swift
│   │   │   └── Notifications/
│   │   │       ├── AlertService.swift
│   │   │       └── HapticFeedbackService.swift
│   │   │
│   │   ├── Utilities/
│   │   │   ├── Constants.swift
│   │   │   ├── Extensions/
│   │   │   │   ├── Date+Extensions.swift
│   │   │   │   ├── Color+Extensions.swift  # Dark trading theme palette
│   │   │   │   └── Double+Extensions.swift # Pip calculations
│   │   │   └── Helpers/
│   │   │       ├── APIKeyManager.swift     # Keychain-backed API key storage
│   │   │       └── NetworkMonitor.swift
│   │   │
│   │   └── Protocols/
│   │       ├── EmotionTrackable.swift
│   │       ├── MarketDataProvider.swift
│   │       └── ExplanationProvider.swift
│   │
│   ├── Features/
│   │   ├── Dashboard/           # Overview screen
│   │   ├── EmotionMonitor/      # Full emotion monitoring + radar + history
│   │   ├── MarketExplainer/     # AI explanation feed + detail view
│   │   ├── TradingGuard/        # Lock screen + Smart Shield + cooldown
│   │   ├── Watchlist/           # Live currency pair watchlist
│   │   ├── Settings/            # Thresholds + notifications + Watch pairing
│   │   └── Onboarding/          # Multi-step intro + permissions
│   │
│   └── Resources/
│       ├── Info.plist            # HealthKit, Camera usage descriptions
│       └── Localizable.strings   # English UI strings
│
├── ForexMindGuardWatch/          # watchOS companion
├── ForexMindGuardTests/          # Unit tests (EmotionAI + Market + Integration)
└── ForexMindGuardUITests/        # XCUITest UI tests
```

---

## Setup & Installation

### Prerequisites

- **Xcode 15+** (for iOS 17 / Swift 5.9 support)
- **iOS 17+ device or simulator** (ARKit face tracking requires real device with TrueDepth camera)
- **Apple Watch** (optional, for heart rate monitoring)
- **Apple Developer Account** (for HealthKit + real device)

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bhavyat81/bhavyat81-ForexMindGuard.git
   cd bhavyat81-ForexMindGuard
   ```

2. **Open in Xcode:**
   ```bash
   open ForexMindGuard.xcodeproj
   # or use Swift Package Manager:
   open Package.swift
   ```

3. **Resolve SPM dependencies** (Xcode does this automatically on first open):
   - Starscream (WebSocket)
   - OpenAI Swift SDK

4. **Configure signing:** Set your Apple Developer team in the project settings.

5. **Add API Keys** (see [API Keys](#api-keys) section below).

6. **Enable capabilities** in Xcode:
   - HealthKit
   - Push Notifications
   - Background Modes (Background fetch, Remote notifications)

7. **Build and run** on device (iOS 17+).

---

## API Keys

> **⚠️ NEVER commit API keys to source control.** ForexMindGuard uses iOS Keychain for secure storage.

### Required APIs

| Service | Purpose | Get Key |
|---------|---------|---------|
| OpenAI API | GPT-4 AI explanations | [platform.openai.com](https://platform.openai.com) |
| NewsAPI.org | Forex news articles | [newsapi.org](https://newsapi.org) |
| TraderMade | Live WebSocket prices | [tradermade.com](https://tradermade.com) |
| Alpha Vantage | Historical data + REST quotes | [alphavantage.co](https://www.alphavantage.co) |

### Setting API Keys

Configure keys via the app's Settings screen or programmatically via `APIKeyManager`:

```swift
// In app Settings / onboarding:
APIKeyManager.shared.store(key: "your-openai-key", for: .openAI)
APIKeyManager.shared.store(key: "your-newsapi-key", for: .newsAPI)
APIKeyManager.shared.store(key: "your-tradermade-key", for: .traderMade)
APIKeyManager.shared.store(key: "your-alphavantage-key", for: .alphaVantage)
```

Keys are stored securely in iOS Keychain with `.whenUnlockedThisDeviceOnly` protection and are **never** stored in `UserDefaults` or the filesystem.

### Demo Mode

Without API keys, the app runs in **Mock/Demo mode**:
- Market data: simulated price ticks via in-app mock timer
- AI explanations: returns `NewsExplanation.sample` static data
- This is the default for SwiftUI Previews and UI testing

---

## Development Roadmap

### v1.0 (Current Scaffold)
- [x] Complete project structure and all Swift source files
- [x] Core models with Codable conformance and sample data
- [x] EmotionAI pipeline (HeartRateService, FaceTracking, StressCalculator, BehaviorAnalyzer, TradingLockManager)
- [x] Market data pipeline (WebSocket, PriceAlertService, CurrencyPairManager)
- [x] AI Explainer pipeline (NewsAPI, OpenAI GPT-4, SentimentAnalyzer)
- [x] All SwiftUI views with dark trading theme
- [x] Apple Watch companion app
- [x] Unit tests and UI tests
- [x] Comprehensive README

### v1.1 (Beta)
- [ ] Train and integrate real CoreML emotion classifier model
- [ ] Live Xcode project (.xcodeproj) with proper targets and entitlements
- [ ] Firebase / Supabase backend for session sync and analytics
- [ ] API key configuration UI in Settings
- [ ] Push notification deep links
- [ ] App Store screenshots and preview

### v1.2 (Production)
- [ ] Personalised resting heart rate baseline calibration
- [ ] Multi-language localisation (ES, DE, JA, ZH)
- [ ] iPad layout
- [ ] Trading journal (manual trade logging + emotion correlation)
- [ ] Session export (PDF report of emotion vs performance)
- [ ] Custom CoreML model trained on real emotion data
- [ ] Live Notification Centre widget

---

## Design System

The app uses a dark trading aesthetic:

| Token | Hex | Usage |
|-------|-----|-------|
| `deepNavy` | `#0A1628` | Primary background |
| `darkCharcoal` | `#1A1A2E` | Card background |
| `electricBlue` | `#00D4FF` | Emotion / info accent |
| `neonGreen` | `#00FF88` | Bullish / positive / safe |
| `dangerRed` | `#FF3B3B` | Bearish / danger / lock |
| `warmGold` | `#FFB800` | Warning / neutral |
| `mutedText` | `#8892A4` | Secondary text |
| `cardBorder` | `#2A3448` | Card borders |

All colors are defined in `Color+Extensions.swift` via the `AppColors` namespace.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Guidelines
- Follow existing Swift style conventions
- Add unit tests for all business logic
- Include SwiftUI `#Preview` providers for all new views
- Never commit API keys or secrets
- Use `// TODO:` markers for incomplete implementations

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Acknowledgements

- [OpenAI](https://openai.com) — GPT-4 AI explanations
- [TraderMade](https://tradermade.com) — Forex WebSocket data
- [Apple Developer Documentation](https://developer.apple.com/documentation/) — HealthKit, ARKit, WatchConnectivity

---

*Built with ❤️ for traders who want to master both the market and their mind.*

