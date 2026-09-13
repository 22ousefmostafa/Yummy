# Yummy 🍽️ — Restaurant Survey App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E)
![State Management](https://img.shields.io/badge/State-BLoC-4CAF50)
![License](https://img.shields.io/badge/License-Unlicensed-lightgrey)

Yummy is a restaurant survey app that lets restaurants gather structured feedback from their customers — ratings, reviews, and satisfaction surveys — and turns that data into clear insights through built-in analytics.

---

## 📱 Features

| Area | Description |
|---|---|
| **Surveys** | Customer satisfaction surveys and feedback forms |
| **Ratings & Reviews** | Star ratings with written comments |
| **Analytics** | Visual charts of survey results |
| **Photo Attachments** | Attach dish or order photos to feedback |
| **Localization** | Full Arabic and English support |
| **Offline Mode** | Works offline with local caching, syncs when back online |

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter |
| Backend / Auth / DB | `supabase_flutter` |
| State Management | `flutter_bloc`, `bloc`, `equatable`, `formz` |
| Navigation | `go_router` |
| Dependency Injection | `get_it`, `injectable` |
| Local Storage | `hive`, `shared_preferences` |
| Charts | `fl_chart` |
| Animations | `flutter_animate`, `lottie` |
| Networking | `dio`, `internet_connection_checker_plus` |
| Media | `image_picker`, `flutter_svg` |
| Localization | `intl` — Cairo (AR) & Poppins (EN) fonts |

## 🌐 Supported Platforms

`Android` · `iOS` · `Web` · `Windows` · `macOS`

## 📂 Project Structure

<details>
<summary>View folder structure</summary>

```
yummy/
├── android/        # Android platform code
├── ios/            # iOS platform code
├── web/            # Web platform code
├── windows/        # Windows platform code
├── macos/          # macOS platform code
├── lib/            # Application source code
├── assets/         # Images, icons, and fonts
├── docs/           # Project documentation
├── supabase/       # Config, migrations, schema
├── test/           # Unit & widget tests
└── pubspec.yaml    # Dependencies & configuration
```

</details>
