import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreenuser extends StatefulWidget {
  const ChatScreenuser({Key? key, required String userId}) : super(key: key);

  @override
  State<ChatScreenuser> createState() => _ChatScreenuserState();
}

class _ChatScreenuserState extends State<ChatScreenuser> {
  final TextEditingController _messageController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  String trainerId = '';
  String trainerName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignedTrainerFromTrainersCollection();
  }

  Future<void> fetchAssignedTrainerFromTrainersCollection() async {
    try {
      final trainersSnapshot =
          await FirebaseFirestore.instance.collection('trainers').get();

      for (var doc in trainersSnapshot.docs) {
        final assignedUsers = List<String>.from(doc['assignedUsers'] ?? []);
        if (assignedUsers.contains(userId)) {
          trainerId = doc.id;
          trainerName = doc['name'] ?? 'Trainer';
          break;
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error finding assigned trainer: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getChatId() {
    return userId.hashCode <= trainerId.hashCode
        ? '${userId}_$trainerId'
        : '${trainerId}_$userId';
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatId = getChatId();
    final message = {
      'text': _messageController.text.trim(),
      'senderId': userId,
      'receiverId': trainerId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(trainerName.isNotEmpty ? trainerName : 'Chat'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isUser = msg['senderId'] == userId;

                          return Container(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blueGrey[700] : Colors.white10,
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
                        onPressed: sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
