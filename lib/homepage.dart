import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentuser = ChatUser(
      id: "0",
      firstName: 'Khurram',
      profileImage:
          'https://yt3.googleusercontent.com/zNy6LCiKzS0E26hc5XOYehueG6HOi-rb4o9JjfxAj_nvJjpZb-qiGM-WCkHwcV3Div6acNEgYEs=s176-c-k-c0x00ffffff-no-rj');
  ChatUser geminiUser = ChatUser(
      id: '1',
      firstName: 'Gemini',
      profileImage:
          "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5))),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 85, 26, 195),
          title: const Column(
            children: [
              Text(
                "Gemini",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 27),
              ),
              Text(
                '• Online',
                style: TextStyle(color: Colors.greenAccent, fontSize: 15),
              )
            ],
          ),
          leading: const Padding(
            padding: EdgeInsets.all(7.0),
            child: CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage(
                  'https://yt3.googleusercontent.com/zNy6LCiKzS0E26hc5XOYehueG6HOi-rb4o9JjfxAj_nvJjpZb-qiGM-WCkHwcV3Div6acNEgYEs=s176-c-k-c0x00ffffff-no-rj'),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    messages.clear();
                  });
                },
                icon: const Icon(
                  Icons.clear_all,
                  size: 35,
                  color: Colors.white,
                ))
          ],
          elevation: 10,
        ),
        backgroundColor: Colors.purple[100],
        body: _buildUi());
  }

  Widget _buildUi() {
    return DashChat(
        messageOptions: const MessageOptions(
            showCurrentUserAvatar: true, showTime: true, maxWidth: 250),
        inputOptions: InputOptions(sendOnEnter: true, trailing: [
          IconButton(
              onPressed: 
                _sendmediaMessage,
              
              icon: const Icon(
                Icons.image,
                size: 40,
                color: Colors.blue,
              ))
        ]),
        currentUser: currentuser,
        onSend: _onSend,
        messages: messages);
  }

  void _onSend(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastmessage = messages.firstOrNull;
        if (lastmessage != null && lastmessage.user == gemini) {
          lastmessage = messages.removeAt(0);
          String resoponse = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastmessage.text += resoponse;
          setState(() {
            messages = [lastmessage!, ...messages];
          });
        } else {
          String resoponse = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
              user: geminiUser, createdAt: DateTime.now(), text: resoponse);
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print('e');
    }
  }
  void _sendmediaMessage()async{
    ImagePicker picker=ImagePicker();
    XFile? file=await picker.pickImage(source: 
    ImageSource.gallery
 );
 if(file!=null){
  ChatMessage chatMessage=ChatMessage(user: currentuser, createdAt: DateTime.now(),
  medias: [
    ChatMedia(url: file.path, fileName: '', type: MediaType.image)
  ],text: "Describe the picture?"
  );
  _onSend(chatMessage);
 }
  }
}
