import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId();

    return Scaffold(
      // Gradient background for the entire screen
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF323244)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                      child: Text(
                        trainerName.isNotEmpty
                            ? trainerName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        trainerName.isNotEmpty ? trainerName : 'Chat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Colors.white),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chatId)
                            .collection('messages')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white));
                          }

                          final messages = snapshot.data!.docs;

                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              final isUser = msg['senderId'] == userId;

                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isUser
                                          ? [
                                              Colors.blueGrey.shade700,
                                              Colors.blueGrey.shade900
                                            ]
                                          : [
                                              Colors.grey.shade800,
                                              Colors.grey.shade700,
                                            ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      )
                                    ],
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                                      bottomRight: Radius.circular(isUser ? 4 : 20),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg['text'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          formatTimestamp(msg['timestamp']),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              // Message input area with rounded container and shadow
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 6,
                      offset: const Offset(0, -3),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.blueGrey[700],
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: sendMessage,
                          splashRadius: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
