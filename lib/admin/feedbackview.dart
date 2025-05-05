import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for formatting timestamp

class FeedbackManagementPage extends StatelessWidget {
  const FeedbackManagementPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        dialogBackgroundColor: Colors.grey[850],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Feedbacks'),
          backgroundColor: Colors.black,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('feedback').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No feedbacks found.'));
            }

            final feedbacks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                var feedbackData = feedbacks[index].data() as Map<String, dynamic>;
                String userId = feedbackData['userId'] ?? '';

                return FutureBuilder<Map<String, dynamic>?>(
                  future: getUserDetails(userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final userData = userSnapshot.data;

                    String feedbackText = feedbackData['feedback'] ?? 'No Feedback';
                    Timestamp? timestamp = feedbackData['timestamp'];
                    String formattedTime = '';
                    if (timestamp != null) {
                      DateTime dateTime = timestamp.toDate();
                      formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
                    }

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              userData != null ? userData['name'] ?? 'User' : 'User',
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email: ${userData?['email'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Feedback:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  feedbackText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Submitted on: $formattedTime",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: userData != null && userData['profileImageUrl'] != null
                                ? NetworkImage(userData['profileImageUrl'])
                                : const AssetImage('assets/default_profile.png') as ImageProvider,
                          ),
                          title: Text(
                            userData != null ? userData['name'] ?? 'Unknown User' : 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                feedbackText,
                                style: const TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              if (userData != null)
                                Text(
                                  userData['email'] ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTime,
                                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
