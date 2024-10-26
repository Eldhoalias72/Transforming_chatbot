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


## Setup

1. Clone the repository:
```bash
git clone [your-repo-url]
cd transforming_chatbot
```

2. Set up environment variables:
   - Copy `.env.example` to create `.env`
   ```bash
   cp .env.example .env
   ```
   - Open `.env` and add your Gemini API key:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Features

- Multiple response modes (Normal, Shakespearean, Python Code, etc.)
- Real-time chat interface
- Dark/Light theme support
- Markdown rendering
- Animated loading states

## Environment Variables

The app uses the following environment variables:
- `GEMINI_API_KEY`: Your Gemini API key from Google

## Development

To run the app in development mode with a different API key:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_development_api_key
