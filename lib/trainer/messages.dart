import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreentrainer extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreentrainer({required this.userId, required this.userName, Key? key})
      : super(key: key);

  @override
  State<ChatScreentrainer> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreentrainer> {
  final TextEditingController _messageController = TextEditingController();
  final String trainerId = FirebaseAuth.instance.currentUser!.uid;

  // Function to get a unique chat ID based on user IDs
  String getChatId() {
    return trainerId.hashCode <= widget.userId.hashCode
        ? '${trainerId}_${widget.userId}'
        : '${widget.userId}_$trainerId';
  }

  // Function to send a message to Firestore
  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatId = getChatId();
    final message = {
      'text': _messageController.text.trim(),
      'senderId': trainerId,
      'receiverId': widget.userId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // Send message to Firestore under the specific chatId
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    _messageController.clear(); // Clear the message input after sending
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(); // Get unique chatId for the chat session

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.userName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(), // Listening to real-time chat updates
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Show most recent messages first
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isTrainer = msg['senderId'] == trainerId; // Check if the sender is the trainer

                    return Container(
                      alignment: isTrainer ? Alignment.centerRight : Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isTrainer ? Colors.blueGrey[700] : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: sendMessage, // Call sendMessage when send icon is pressed
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
