import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/Widget/chat_messages.dart';
import 'package:flutter_chat_app/Widget/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() {

    return _ChatScreen();
  }

}
class _ChatScreen extends State<ChatScreen>{
  void setupPushNotification() async{
    final fcm=FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token=await fcm.getToken();
    print(token);
  }
  @override
  void initState() {
    super.initState();
    setupPushNotification();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ))
        ],
      ),
      body: const Center(
        child: Column(
          children: [Expanded(child: ChatMessages()), NewMessage()],
        ),
      ),
    );
  }
}
