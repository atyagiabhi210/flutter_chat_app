import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessage();
  }
}

class _NewMessage extends State<NewMessage> {
  var _messageController = TextEditingController();

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    _messageController.clear();
    if (enteredMessage
        .trim()
        .isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    //send to firebase
    final userData = await FirebaseFirestore.instance.collection('user').doc(
        FirebaseAuth.instance.currentUser?.uid).get();
    FirebaseFirestore.instance.collection('chats').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'userName': userData.data()!['userame'],
      'userImage':userData.data()!['image_url']
    });


  }

  @override
  void dispose() {

    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            enableSuggestions: true,
            autocorrect: true,
            decoration: InputDecoration(labelText: 'Send a message'),
          )),
          IconButton(
              onPressed: () {

                _submitMessage();
                print("Hellp");
              },
              icon: Icon(
                Icons.send,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onBackground,
              ))
        ],
      ),
    );
  }
}
