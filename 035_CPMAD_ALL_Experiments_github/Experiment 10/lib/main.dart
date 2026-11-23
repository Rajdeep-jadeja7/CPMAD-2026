import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const RealTimeChatApp());
}

// -------------------------------------------------------------
// CHAT MESSAGE MODEL
// -------------------------------------------------------------
class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final String room;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.room,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'room': room,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      sender: map['sender'],
      text: map['text'],
      room: map['room'] ?? 'General',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

// -------------------------------------------------------------
// FIRESTORE STREAM SERVICE (Simulating Cloud Firestore Stream)
// -------------------------------------------------------------
class MockFirestoreService {
  static final List<ChatMessage> _database = [
    ChatMessage(
      id: '1',
      sender: 'Prof. Sharma',
      text: 'Welcome everyone to the CPMAD Real-Time Chat room!',
      room: 'General',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      id: '2',
      sender: 'Rahul',
      text: 'Hello Sir, excited to learn Flutter and Firebase streams!',
      room: 'General',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      id: '3',
      sender: 'Rahul',
      text: 'Anyone working on Experiment 10?',
      room: 'Project Hub',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  static final StreamController<List<ChatMessage>> _controller =
      StreamController<List<ChatMessage>>.broadcast();

  // Retrieve messages using a Stream (like Firestore .snapshots())
  static Stream<List<ChatMessage>> getMessagesStream(String room) {
    // Emit initial data
    Future.microtask(() {
      _controller.add(_database.where((m) => m.room == room).toList());
    });
    return _controller.stream.map((list) => list.where((m) => m.room == room).toList());
  }

  // Create and store new message (Firestore .add())
  static void sendMessage(String sender, String text, String room) {
    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: sender,
      text: text,
      room: room,
      timestamp: DateTime.now(),
    );
    _database.add(newMsg);
    _controller.add(List.from(_database));
  }

  // Edit existing message (Firestore .update())
  static void editMessage(String id, String newText) {
    final index = _database.indexWhere((m) => m.id == id);
    if (index != -1) {
      final old = _database[index];
      _database[index] = ChatMessage(
        id: old.id,
        sender: old.sender,
        text: newText,
        room: old.room,
        timestamp: old.timestamp,
      );
      _controller.add(List.from(_database));
    }
  }

  // Delete message (Firestore .delete())
  static void deleteMessage(String id) {
    _database.removeWhere((m) => m.id == id);
    _controller.add(List.from(_database));
  }
}

// -------------------------------------------------------------
// APP ENTRY POINT
// -------------------------------------------------------------
class RealTimeChatApp extends StatelessWidget {
  const RealTimeChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real-Time Chat App',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const ChatRoomScreen(),
    );
  }
}

// -------------------------------------------------------------
// CHAT SCREEN WITH MULTIPLE ROOMS & SEARCH (POST-LAB INCLUDED)
// -------------------------------------------------------------
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final String _currentUser = 'Rahul';

  // Post-Lab Task 1: Multiple Chat Rooms
  String _selectedRoom = 'General';
  final List<String> _rooms = ['General', 'Project Hub', 'Exams & Doubts'];

  // Post-Lab Task 2: Search Feature
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    MockFirestoreService.sendMessage(_currentUser, _messageController.text.trim(), _selectedRoom);
    _messageController.clear();
  }

  void _openEditDialog(ChatMessage msg) {
    final editController = TextEditingController(text: msg.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  MockFirestoreService.editMessage(msg.id, editController.text.trim());
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              )
            : Text('Room: $_selectedRoom'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
          // Dropdown to switch chat rooms
          PopupMenuButton<String>(
            icon: const Icon(Icons.meeting_room),
            tooltip: 'Switch Room',
            onSelected: (room) {
              setState(() {
                _selectedRoom = room;
              });
            },
            itemBuilder: (context) {
              return _rooms.map((r) {
                return PopupMenuItem(value: r, child: Text(r));
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // StreamBuilder retrieving real-time messages
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: MockFirestoreService.getMessagesStream(_selectedRoom),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No messages yet in $_selectedRoom room.\nSend the first message!'),
                  );
                }

                var messages = snapshot.data!;
                if (_searchQuery.isNotEmpty) {
                  messages = messages
                      .where((m) => m.text.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.sender == _currentUser;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.indigo.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.sender,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isMe ? Colors.indigo : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(msg.text, style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    child: const Icon(Icons.edit, size: 14, color: Colors.blueGrey),
                                    onTap: () => _openEditDialog(msg),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    child: const Icon(Icons.delete, size: 14, color: Colors.redAccent),
                                    onTap: () => MockFirestoreService.deleteMessage(msg.id),
                                  ),
                                ],
                              ],
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

          // Message Input Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
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
