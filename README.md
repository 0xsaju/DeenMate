```mermaid
graph TD
    UI_Main[User Interface (UI)] --> Platform[Platform Layer]
    Platform --> AppLayer[Application Layer (Flutter)]
    AppLayer --> Domain[Domain Layer (Clean Architecture)]
    Domain --> Data[Data Layer]
    Data --> External[External APIs & Services]
    Data --> LocalStorage[Local Storage]

    subgraph UI [User Interface (UI)]
        UI1[HomeAsScreen]
        UI2[Prayer Times Screen]
        UI3[Qibla Finder Screen]
        UI4[Zakat Calculator Screen]
        UI5[Islamic Content Screen]
        UI6[Settings Screen]
        UI7[Onboarding Screen]
    end

    subgraph Platform [Platform Layer]
        Plat1[iOS]
        Plat2[Android]
        Plat3[Web]
        Plat4[Desktop (macOS/Windows)]
    end

    subgraph AppLayer [Application Layer - Flutter 3.x + Riverpod]
        App1[State Management: Riverpod 2.x]
        App2[Navigation: GoRouter]
        App3[Theming: Material 3 + Islamic Design]
        App4[Localization: en, bn, ar]
        App5[Responsive Layout Engine]
    end

    subgraph Domain [Domain Layer (Business Logic)]
        Dom1[Prayer Times Use Cases]
        Dom2[Qibla Direction Logic]
        Dom3[Zakat Calculation Logic]
        Dom4[Islamic Content Manager]
        Dom5[User Preferences]
        Dom6[Entities: PrayerTime, Dua, Hadith, ZakatAsset, etc.]
    end

    subgraph Data [Data Layer]
        Data1[Repository Interfaces]
        Data2[PrayerTimesRepository]
        Data3[ZakatRepository]
        Data4[ContentRepository]
        Data5[SettingsRepository]
    end

    subgraph LocalStorage [Local Storage]
        Loc1[Hive - Local DB]
        Loc2[SharedPreferences - Settings]
        Loc3[PDF Generator - Reports]
    end

    subgraph External [External APIs & Services]
        Ext1[AlAdhan API - Prayer Times]
        Ext2[Metal Prices API - Gold/Silver]
        Ext3[Currency Conversion API]
        Ext4[Google Maps / Location Services]
        Ext5[Notification Service (Firebase/Local)]
    end

    %% Connections
    UI_Main --> AppLayer
    AppLayer --> Domain
    Domain --> Data
    Data --> LocalStorage
    Data --> External

    %% Bidirectional for state
    App1 -->|Provides State| AppLayer
    App1 -->|Listens to| Domain

    %% Notifications
    Ext5 -->|Push Alerts| UI2
    App1 -->|Schedules| Ext5

    %% Localization
    App4 -->|Loads| assets/translations/en.json
    App4 -->|Loads| assets/translations/bn.json
    App4 -->|Loads| assets/translations/ar.json

    %% Theme
    App3 -->|Islamic Colors & Fonts| UI_Main

    %% Styles
    style UI_Main fill:#f0f8e8,stroke:#2E7D32,stroke-width:2px
    style AppLayer fill:#e8f4f8,stroke:#1565C0,stroke-width:2px
    style Data fill:#fff8e1,stroke:#FF8F00,stroke-width:2px
    style External fill:#ffebee,stroke:#D32F2F,stroke-width:2px
    style LocalStorage fill:#f3e5f5,stroke:#7B1FA2,stroke-width:2px
```
