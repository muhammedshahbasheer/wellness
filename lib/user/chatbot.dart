import 'package:flutter/material.dart';

class DietChatBotScreen extends StatefulWidget {
  @override
  _DietChatBotScreenState createState() => _DietChatBotScreenState();
}

class _DietChatBotScreenState extends State<DietChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': _controller.text});
      _messages.add({'sender': 'bot', 'text': _generateDietResponse(_controller.text)});
    });
    _controller.clear();
  }

  String _generateDietResponse(String query) {
    query = query.toLowerCase();
    if (query.contains("weight loss")) {
      return "For weight loss, try a high-protein diet with plenty of vegetables and whole grains.";
    } else if (query.contains("muscle gain")) {
      return "For muscle gain, focus on lean proteins, complex carbs, and healthy fats.";
    } else if (query.contains("healthy diet")) {
      return "A balanced diet includes fruits, vegetables, lean proteins, and whole grains.";
    } else {
      return "I can help with diet plans! Ask about weight loss, muscle gain, or general healthy eating.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Diet ChatBot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about diet...",
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
