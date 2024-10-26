# Transforming Chatbot

A Flutter application that uses the Gemini API to create a versatile chatbot with multiple response modes.

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
```