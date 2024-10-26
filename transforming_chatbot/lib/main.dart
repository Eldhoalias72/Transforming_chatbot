import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart'; 
import 'config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found. Using dart-define values if available.');
  }
  // Run the app
  runApp(const GeminiApp());
}
class GeminiApp extends StatelessWidget {
  const GeminiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const GeminiHomePage(),
    );
  }
}

class ResponseMode {
  final String name;
  final IconData icon;
  final String prompt;

  const ResponseMode(this.name, this.icon, this.prompt);
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class GeminiHomePage extends StatefulWidget {
  const GeminiHomePage({Key? key}) : super(key: key);

  @override
  _GeminiHomePageState createState() => _GeminiHomePageState();
}

class _GeminiHomePageState extends State<GeminiHomePage>with SingleTickerProviderStateMixin  {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _isLoading = false;
  String _selectedMode = 'Normal';
  List<ChatMessage> _chatHistory = [];
  final String geminiAPIKey = Config.geminiApiKey;

  final List<ResponseMode> _responseModes = const [
    ResponseMode('Normal', Icons.chat_bubble_outline, ''),
    ResponseMode('Shakespearean', Icons.theater_comedy, 'Respond in Shakespearean English to: '),
    ResponseMode('Python Code', Icons.code, 'Write a Python function that: '),
    ResponseMode('Poem', Icons.music_note, 'Compose a poem about: '),
    ResponseMode('Sarcastic', Icons.sentiment_very_satisfied, 'Respond with sarcastic humor to: '),
    ResponseMode('Explain', Icons.school, 'Explain in simple terms: '),
  ];

  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> getAnswer(String question) async {
    if (question.trim().isEmpty) {
      _showSnackBar('Please enter a question');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final selectedMode = _responseModes.firstWhere((mode) => mode.name == _selectedMode);
    final modifiedQuestion = selectedMode.prompt + question;
    
    final userMessage = ChatMessage(
      content: question,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _chatHistory.add(userMessage);
      _questionController.clear();
    });

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$geminiAPIKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": modifiedQuestion}]}],
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String answer = '';
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          answer = data['candidates'][0]['content']['parts'][0]['text'] ?? "No answer available.";
        } else {
          answer = "No response available.";
        }

        final aiMessage = ChatMessage(
          content: answer,
          isUser: false,
          timestamp: DateTime.now(),
        );

        setState(() {
          _chatHistory.add(aiMessage);
        });
        
        _scrollToBottom();
      } else {
        _handleError('Error: ${response.statusCode}');
      }
    } catch (error) {
      _handleError('Failed to get an answer: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleError(String errorMessage) {
    final errorChat = ChatMessage(
      content: errorMessage,
      isUser: false,
      timestamp: DateTime.now(),
      isError: true,
    );

    setState(() {
      _chatHistory.add(errorChat);
    });
    _showSnackBar(errorMessage);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(8),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _chatHistory.clear();
              });
              _showSnackBar('Chat cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Row(
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Transforming',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            Text(
              'Bot',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatHistory.isEmpty
                ? WelcomeScreen(animationController: _animationController)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = _chatHistory[index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          ResponseModeSelector(
            selectedMode: _selectedMode,
            responseModes: _responseModes,
            onModeSelected: (mode) {
              setState(() {
                _selectedMode = mode;
              });
            },
          ),
          MessageInputField(
            controller: _questionController,
            isLoading: _isLoading,
            onSubmit: getAnswer,
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final AnimationController animationController;

  const WelcomeScreen({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add a Lottie animation here
            Lottie.network(
              'https://assets1.lottiefiles.com/packages/lf20_qwl4gi2d.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 4 * animationController.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(              
                      'Welcome to TransformingBot!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ask me anything and choose how you want me to respond using the style buttons below.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isError
              ? Theme.of(context).colorScheme.errorContainer
              : message.isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.content,
              style: TextStyle(
                color: message.isUser
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ResponseModeSelector extends StatelessWidget {
  final String selectedMode;
  final List<ResponseMode> responseModes;
  final Function(String) onModeSelected;

  const ResponseModeSelector({
    Key? key,
    required this.selectedMode,
    required this.responseModes,
    required this.onModeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: responseModes.length,
        itemBuilder: (context, index) {
          final mode = responseModes[index];
          final isSelected = mode.name == selectedMode;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                minWidth: 80, // minimum width
              ),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode.icon,
                      size: 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        mode.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onModeSelected(mode.name),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                labelPadding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        },
      ),
    );
  }
}


class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSubmit;

  const MessageInputField({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (text) {
                  if (text.isNotEmpty && !isLoading) {
                    onSubmit(text);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            MaterialButton(
              onPressed: isLoading ? null : () => onSubmit(controller.text),
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}