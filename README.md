# TransformingBot 🤖

A modern, Flutter-based chat interface that leverages Google's Gemini AI to provide responses in various creative styles. The app features a sleek Material Design 3 interface with support for both light and dark themes.



## 🌟 Features

- **Multiple Response Styles:**
  - Normal conversation
  - Shakespearean English
  - Python Code Generation
  - Poetry Composition
  - Sarcastic Responses
  - Simple Explanations

- **Modern UI Elements:**
  - Material Design 3 implementation
  - Dynamic theme support (light/dark)
  - Smooth animations
  - Interactive message bubbles
  - Real-time response indicators

- **Technical Features:**
  - Integration with Google's Gemini API
  - Markdown support for formatted responses
  - Message timestamp display
  - Chat history management
  - Error handling with user feedback
  - Responsive design for various screen sizes

## 🚀 Getting Started

### Prerequisites

- Flutter (latest version)
- Dart SDK
- Google Gemini API key
- Dependencies:
  - http
  - google_fonts
  - flutter_markdown
  - lottie

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/transforming-bot.git
```

2. Navigate to the project directory:
```bash
cd transforming-bot
```

3. Install dependencies:
```bash
flutter pub get
```

4. Add your Gemini API key:
- Open `lib/main.dart`
- Replace `your_api_key_here` with your actual Gemini API key:
```dart
final String geminiAPIKey = 'your_api_key_here';
```

5. Run the app:
```bash
flutter run
```
