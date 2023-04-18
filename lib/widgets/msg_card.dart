import 'package:chat_application_with_firebase/api/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.formId
        ? _greenMessage()
        : _blueMessage();
  }

  //sender or another user message.
  Widget _blueMessage() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      //message content
      Flexible(
        child: Container(
          padding: EdgeInsets.all(mq.width * .04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04, vertical: mq.height * .01),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlue),
            color: const Color.fromARGB(255, 221, 245, 255),
            //making border curve.
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30)),
          ),
          child: Text(widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ),
      ),

      //message time
      Padding(
        padding: EdgeInsets.only(right: mq.width * .04),
        child: Text(
          widget.message.sent,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      )
    ]);
  }

  //our or user message.
  Widget _greenMessage() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      //message time
      Row(
        children: [
          //for adding some space
          SizedBox(width: mq.width * .04),

          //double tick blue icon for message read
          const Icon(
            Icons.done_all_rounded,
            color: Colors.blue,
            size: 20,
          ),

          //for adding some space
          const SizedBox(width: 2),

          //read line
          Text(
            "${widget.message.read} 12:00 AM",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),

      //message content
      Flexible(
        child: Container(
          padding: EdgeInsets.all(mq.width * .04),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04, vertical: mq.height * .01),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.lightGreen),
            color: const Color.fromARGB(255, 218, 255, 176),
            //making border curve.
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)),
          ),
          child: Text(widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ),
      ),
    ]);
  }
}
