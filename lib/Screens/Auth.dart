import 'dart:io';

//import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/Widget/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  var enteredUsername='';
  var _isLogin = true;
  var enteredEmail = '';
  var enteredPass = '';
  File? selectedImage;
  var _isUploading = false;
  var i = 1;
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && selectedImage == null) {
      return;
    }

    //save triggers a special function onSavedFuntion and gets the currently entered value

    _formKey.currentState!.save();
    try {
      setState(() {
        _isUploading = true;
      });
      if (_isLogin) {
        //log in users

        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPass);

      } else {
        final userCredentials =await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPass);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('User_Images')
            .child('${userCredentials.user?.uid}.jpg');
        i++;
        await storageRef.putFile(selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl);

       await FirebaseFirestore.instance
            .collection('user')
            .doc(userCredentials.user?.uid)
            .set({
          'username':enteredUsername,
          'email':enteredEmail,
          'image_url':imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'authentication failed')));

    }
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            //to center all contents inside the column
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets\images\chat.png'),
              )*/
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(onPickImage: (pickedImage) {
                              selectedImage = pickedImage;
                            }),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('EMAIL'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },

                            onSaved: (newValue) {
                              enteredEmail = newValue!;
                            },
                          ),
                          if(!_isLogin)
                          TextFormField(
                            validator: (value) {
                              if(value==null||value.isEmpty||value.trim().length<4){
                                return 'Please enter a valid username atleast 4 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(label:const Text('Username'),),
                            enableSuggestions: false,
                            onSaved: (newValue) {
                                enteredUsername=newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Password'),
                            ),
                            obscureText: true,
                            //hides the character that's being added
                            //autocorrect: false,
                            //textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@') ||
                                  value.trim().length < 6) {
                                return 'Please enter atleast 6 characters';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              enteredPass = newValue!;
                            },
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          if (_isUploading) CircularProgressIndicator(),
                          if (!_isUploading)
                            ElevatedButton(
                              onPressed: () {
                                _submit();
                              },
                              child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                            ),
                          if (!_isUploading)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account'
                                    : 'I already Have an Account'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer))
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
