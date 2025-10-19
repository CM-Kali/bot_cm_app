import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_key.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];


  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;
    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String botResponse =
            data['candidates'][0]['content']['parts'][0]['text'] ?? "No response";

        setState(() {
          _messages.add({'sender': 'bot', 'text': botResponse});
        });
      } else {
        setState(() {
          _messages.add({'sender': 'bot', 'text': 'Error: ${response.statusCode}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'Error: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}